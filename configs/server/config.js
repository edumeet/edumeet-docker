const os = require("os");
const ifaces = os.networkInterfaces();

function getListenIPs() {
  let listenIP = [];
  Object.keys(ifaces).forEach(function(ifname) {
    var alias = 0;

    ifaces[ifname].forEach(function(iface) {
      if (
        (iface.family !== "IPv4" &&
          (iface.family !== "IPv6" || iface.scopeid !== 0)) ||
        iface.internal !== false
      ) {
        // skip over internal (i.e. 127.0.0.1) and non-ipv4 or ipv6 non global addresses
        return;
      }
      listenIP.push({ ip: iface.address, announcedIp: null });

      ++alias;
    });
  });
  return listenIP;
}

module.exports = {
  // oAuth2 conf
  /* auth :
	{

		// The issuer URL for OpenID Connect discovery
		// The OpenID Provider Configuration Document
		// could be discovered on:
		// issuerURL + '/.well-known/openid-configuration'

		// issuerURL 	    : 'https://example.com',
		// clientOptions     :
		// {
			client_id     : '',
			client_secret : '',
			scope         : 'openid email profile',
			// where client.example.com is your multiparty meeting server
			redirect_uri  : 'https://client.example.com/auth/callback'
		}
	},*/
  // session cookie secret
  cookieSecret: "T0P-S3cR3t_cook!e",
  cookieName: "multiparty-meeting.sid",
  tls: {
    cert: `${__dirname}/../certs/cert.pem`,
    key: `${__dirname}/../certs/privkey.pem`
  },
  // Listening port for https server.
  listeningPort: 443,
  // Any http request is redirected to https.
  // Listening port for http server.
  listeningRedirectPort: 80,
  // If this is set to true, only signed-in users will be able
  // to join a room directly. Non-signed-in users (guests) will
  // always be put in the lobby regardless of room lock status.
  // If false, there is no difference between guests and signed-in
  // users when joining.
  requireSignInToAccess: true,
  // This flag has no effect when requireSignInToAccess is false
  // When truthy, the room will be open to all users when the first
  // authenticated user has already joined the room.
  activateOnHostJoin: true,
  // Mediasoup settings
  mediasoup: {
    numWorkers: Object.keys(os.cpus()).length,
    // mediasoup Worker settings.
    worker: {
      logLevel: "warn",
      logTags: ["info", "ice", "dtls", "rtp", "srtp", "rtcp"],
      rtcMinPort: 40000,
      rtcMaxPort: 49999
    },
    // mediasoup Router settings.
    router: {
      // Router media codecs.
      mediaCodecs: [
        {
          kind: "audio",
          mimeType: "audio/opus",
          clockRate: 48000,
          channels: 2
        },
        {
          kind: "video",
          mimeType: "video/h264",
          clockRate: 90000,
          parameters: {
            "packetization-mode": 1,
            "profile-level-id": "42e01f",
            "level-asymmetry-allowed": 1,
            "x-google-start-bitrate": 1000
          }
        }
      ]
    },
    // mediasoup WebRtcTransport settings.
    webRtcTransport: {
      listenIps: getListenIPs(),
      maxIncomingBitrate: 1500000,
      initialAvailableOutgoingBitrate: 1000000
    }
  }
};
