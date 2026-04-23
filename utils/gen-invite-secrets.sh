#!/bin/bash
#
# gen-invite-secrets.sh
#
# Generates the two secrets required for the calendar-invite workers:
#   - invites.encryptionKey   : 64-char hex key for AES-256-GCM at-rest encryption of
#                               per-tenant SMTP/IMAP passwords stored in tenantInviteConfigs
#   - invites.rsvpTokenSecret : HMAC-SHA256 secret used to mint per-attendee RSVP tokens
#
# Use this on existing installs that already have configs/mgmt/default.json set up.
# It prints the JSON block to paste next to the existing "authentication" block.
# It does NOT modify any files.
#
# For fresh installs, run-me-first.sh writes these values automatically.
#

RED='\033[1;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NOCOLOR='\033[0m'

ENC_KEY=`tr -dc A-Fa-f0-9 </dev/urandom | head -c 64`
RSVP_KEY=`tr -dc A-Za-z0-9 </dev/urandom | head -c 64`

echo -e "${GREEN}Generated new invite secrets.${NOCOLOR}"
echo
echo -e "${YELLOW}Paste the following block into configs/mgmt/default.json${NOCOLOR}"
echo -e "${YELLOW}at the top level, next to the existing \"authentication\" block:${NOCOLOR}"
echo
echo '	"invites": {'
echo "		\"encryptionKey\": \"${ENC_KEY}\","
echo "		\"rsvpTokenSecret\": \"${RSVP_KEY}\","
echo '		"imapPollIntervalMs": 60000'
echo '	}'
echo
echo -e "${RED}IMPORTANT:${NOCOLOR} keep these values safe and do NOT rotate them after"
echo "          tenants have configured invite email credentials — the"
echo "          encryptionKey is required to decrypt previously stored"
echo "          SMTP/IMAP passwords. Restart edumeet-management-server"
echo "          after adding the block."
