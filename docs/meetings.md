# Meetings and calendar invitations

## Calendar invites

edumeet can send ICS calendar invites (RFC 5545 / RFC 6047 iTIP) for meetings scheduled in existing rooms. Attendees receive the invite in Gmail/Outlook/Apple Calendar, RSVP natively from their mail client, and the response flows back into edumeet via IMAP. Recurring meetings are supported.

### Prerequisites

Each tenant that wants to send invites needs an **SMTP mailbox** (e.g. `invites@tenantA.com`). The same mailbox is used to send invites *and* (optionally) receive RSVP replies via IMAP. Use a dedicated mailbox, not a human inbox: the poller reads unseen replies, marks handled replies as seen, and can delete old seen messages. Opening the mailbox in a mail client can mark replies read before the poller sees them.

**Sharing one mailbox across tenants is supported.** Several tenants can point at the same `invitation@…` account — the reply poller deduplicates by mailbox (host:port:user) and runs a single poller per unique mailbox, so RSVPs are processed once and routed to the correct meeting regardless of which tenant owns it. This lets you offer invites to tenants who don't want to provision their own mailbox.

When separate deployments share a mailbox, a reply not recognized by one
deployment is initially left unread. A reply with a message date older than
seven days can be marked seen and later deleted, even if another deployment
has not processed it.

For best deliverability, ensure the mailbox's domain has valid **SPF and DKIM** records. Without them, invites will land in spam.

### Fresh install

On a fresh install, `./utils/run-me-first.sh` generates `invites.encryptionKey` for AES-256-GCM encryption of stored SMTP/IMAP passwords and writes it into `configs/mgmt/default.json`. It also generates `invites.rsvpTokenSecret`, reserved for a future per-attendee, link-based RSVP flow. The encryption key is required for invite workers; the current email-based invitation and reply flow does not require or verify the RSVP token.

### Existing install

First check whether `configs/mgmt/default.json` already has an `"invites"`
block. Keep any existing secrets and settings: replacing the encryption key
can make stored mailbox passwords unreadable. If `encryptionKey` is missing,
generate new secrets with:
```
./utils/gen-invite-secrets.sh
```
This prints an `"invites": { ... }` JSON block, including the optional
`rsvpTokenSecret`. Add it at the top level of `configs/mgmt/default.json` if the
block is absent; otherwise add only the missing values. Do not overwrite
existing keys or settings. Restart the management server:
```
docker compose restart edumeet-management-server
```

> **Do not replace the encryption key** after tenants have configured invite credentials without a migration plan. It is required to decrypt previously stored SMTP/IMAP passwords; replacing it would invalidate those credentials. Back up the encryption key and any configured RSVP token secret securely.

### Optional invite settings

The `"invites"` block supports two optional tuning knobs:

- **`imapPollIntervalMs`** (default `60000`) — how often the poller checks each tenant's IMAP inbox for new RSVP replies, in milliseconds.
- **`imapRetentionDays`** (default `30`) — the age after which the poller deletes messages marked `\Seen`. This includes **any** seen message, even if it was marked read by another mail client or was not processed by eduMEET. Unseen messages are not deleted by this cleanup. Values:
  - `0` — delete seen messages dated before today, including older messages on the next poll. IMAP `SEARCH BEFORE` compares dates rather than instants, so today's mail is not purged until tomorrow
  - positive integer (e.g. `30`) — keep for N days, then delete
  - `-1` — fully disable cleanup; nothing is ever deleted

### Per-tenant configuration (via management UI)

1. Log in to `https://yourdomain.com/mgmt-admin/` as a tenant admin or tenant owner.
2. Go to **Tenants**, click the tenant row to open the edit dialog.
3. Expand the **Invite email (SMTP/IMAP)** accordion.
4. Fill in the organizer address (the From: line, e.g. `invites@tenantA.com`), organizer display name, SMTP block (host, port, TLS, user, password) and optionally IMAP block.
5. Apply.

Invite workers boot automatically for that tenant — no restart needed.

Enabling invites is **validated**: if the *Invites enabled* box is ticked, the save is rejected unless the organizer address and SMTP host/port/user/password are present (an IMAP host, if given, also requires its user/password). This prevents an "enabled-but-unusable" config that would silently never send. If the server's `invites.encryptionKey` is missing, the dialog and Meetings tab show a warning; invite workers cannot use the saved credentials until an administrator configures the key.

The **From:** line is `"Organizer Name via Tenant Name" <invites@tenantA.com>`, so attendees can tell invites apart even when several tenants share one mailbox. The **meeting organizer is automatically added as an accepted attendee and also receives the invite** — creating a meeting in edumeet does not put the event in the organizer's own Gmail/Outlook calendar, so the iMIP email is the only path there.

Each meeting picks an **invite language** (the email subject/body locale). All bundled UI languages have a template; anything without one falls back to English. Date/times in the body are rendered in the meeting's chosen timezone.

Sends are **pooled and rate-limited** (one SMTP connection per mailbox, ≤10 messages/second) so a large attendee list won't trip provider concurrency limits. This smooths bursts but does **not** enforce per-day provider quotas.

### IMAP is optional

If IMAP is left blank, invites still work: attendees receive the ICS and can RSVP from their calendar client. The only thing missing is per-attendee RSVP status surfaced in the edumeet admin UI. Within the same provider (Google↔Google, Outlook↔Outlook) attendees still see each other's status natively. Tenants on Gmail/M365 that can't provide basic-auth IMAP can skip it.

> **RSVPs from Thunderbird + Google Calendar are unreliable.** When Thunderbird's calendar event comes from a Google Calendar (via CalDAV / Provider for Google), accepting or declining the invite in Thunderbird writes the new response to Google via CalDAV but does **not** send an iMIP REPLY email. Because Google is not the meeting organizer in this setup, Google will not proxy an RSVP email either. The change is invisible to edumeet and the attendee stays as NEEDS-ACTION in the admin UI. For a reliable RSVP, respond on [calendar.google.com](https://calendar.google.com) directly — that path does send an iMIP REPLY.

### Landing page

Logged-in users see a calendar icon button next to the login/logout button in the landing, join, and lobby dialogs. The button is only visible when the user's tenant has invites enabled. Clicking opens a dialog listing upcoming meetings (both organized by and invited to the user) with inline Join buttons, a refresh button, and a shortcut to the full management page.

## Meetings-only rooms

A room owner can restrict a managed room to scheduled meetings. Every meeting receives a **meeting token** when it is created (12 characters, shown in the Meetings table of `/mgmt-admin` and embedded in the invitation link as `?meetingToken=...`). With **Meetings only** enabled on the room (in the room settings dialog of the meeting UI or in the Rooms table of `/mgmt-admin`), participants entering the room must present the token of a meeting scheduled for that room, including the room owner. A verified reconnect can resume without sending it again.

- The first participant with a valid token binds the room to that meeting. Subsequent new participants must present the same token until the room empties again; a token for another meeting is refused.
- Without a token, or with a wrong one, the join dialog shows an error and a **Meeting token** field for manual entry.
- Invitations for meetings in such a room carry the token in the join link and in the ICS `LOCATION`. Switching the setting on or off re-sends the invitation with the updated link to attendees who had already received one, for meetings that are not over yet; past meetings are left alone.
- Switching the setting takes effect immediately for newcomers. People already in the room are not affected.
- Tokens are not rotated; the time during which a token is usable is described
  below. Deleting a meeting prevents its token from starting a new room session, but an already active room continues
  accepting its bound token until the room closes or Meetings only is disabled.
- Unmanaged rooms never have this restriction.
- Verified bots are exempt from the meeting-token check but cannot open an empty
  room. See [bot admission](https://github.com/edumeet/edumeet/blob/main/BOTS.md#how-a-bot-gets-in).

**Since 4.2-20261126-stable:** The meeting token is normally usable from one hour before
the meeting until one hour after it ends, or around each occurrence of a series.
If the meeting runs over, the hour starts when the room empties; entering during
that hour starts it again when the room next empties. Before the window the join
dialog shows the start time; after it, the dialog says the meeting is over.
Switching Meetings only off and on no longer releases an active room from its
bound meeting. This needs the management server, room server and client of that
release or newer.
