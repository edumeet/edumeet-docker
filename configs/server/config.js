const os = require('os');
// const fs = require('fs');
// const tunnel = require('tunnel');

// const AwaitQueue = require('awaitqueue');
// const axios = require('axios');

// To gather ip address only on interface like eth0, ens0p3
const ifaceWhiteListRegex = '^(eth.*)|(ens.*)'

function getListenIps() {
	let listenIP = [];
	const ifaces = os.networkInterfaces();
	Object.keys(ifaces).forEach(function (ifname) {
		if (ifname.match(ifaceWhiteListRegex)) {
			ifaces[ifname].forEach(function (iface) {
				if (
					(iface.family !== "IPv4" &&
						(iface.family !== "IPv6" || iface.scopeid !== 0)) ||
					iface.internal !== false
				) {
					// skip over internal (i.e. 127.0.0.1) and non-ipv4 or ipv6 non global addresses
					return;
				}
				listenIP.push({ ip: iface.address, announcedIp: null });
			});
		}
	});
	return listenIP;
}

module.exports =
{
	// Auth conf
	/*
	auth :
	{
		// Always enabled if configured
		lti :
		{
			consumerKey    : '_bo2uqnwon1ym4qkte5hhd4fzlnoufvts5h3hblxzcy',
			consumerSecret : '_1xpnaa4iw36cwpnx7991e630yo0u4044so1crhvcnz'
		},

		// Auth strategy to use (default oidc)
		strategy : 'oidc',
		oidc :
		{
			// The issuer URL for OpenID Connect discovery
			// The OpenID Provider Configuration Document
			// could be discovered on:
			// issuerURL + '/.well-known/openid-configuration'

			// e.g. google OIDC config
			// Follow this guide to get credential:  
			// https://developers.google.com/identity/protocols/oauth2/openid-connect
			// use this issuerURL
			// issuerURL     : 'https://accounts.google.com/',
			
			issuerURL     : 'https://example.com',
			clientOptions :
			{
				client_id     : '',
				client_secret : '',
				scope       		: 'openid email profile',
				// where client.example.com is your edumeet server
				redirect_uri  : 'https://client.example.com/auth/callback'
			},
			/*
			HttpOptions   :
			{
  				timeout: 5000,
				agent: 
				{
                	https:tunnel.httpsOverHttp({
                           proxy: {
                                host: 'proxy',
                               port: 3128
                           }
                 	})
  				}
			}
			*//*
		},
		saml :
		{
			// where edumeet.example.com is your edumeet server
			callbackUrl    : 'https://edumeet.example.com/auth/callback',
			issuer         : 'https://edumeet.example.com',
			entryPoint     : 'https://openidp.feide.no/simplesaml/saml2/idp/SSOService.php',
			privateCert    : fs.readFileSync('config/saml_privkey.pem', 'utf-8'),
			signingCert    : fs.readFileSync('config/saml_cert.pem', 'utf-8'),
			decryptionPvk  : fs.readFileSync('config/saml_privkey.pem', 'utf-8'),
			decryptionCert : fs.readFileSync('config/saml_cert.pem', 'utf-8'),
			// Federation cert
			cert           : fs.readFileSync('config/federation_cert.pem', 'utf-8')
		},

		// to create password hash use: node server/utils/password_encode.js cleartextpassword
		local :
		{
			users : [
				{
					id           : 1,
					username     : 'alice',
					passwordHash : '$2b$10$PAXXw.6cL3zJLd7ZX.AnL.sFg2nxjQPDmMmGSOQYIJSa0TrZ9azG6',
					displayName  : 'Alice',
					emails       : [ { value: 'alice@atlanta.com' } ],
					meet_roles   : [ ]
				},
				{
					id           : 2,
					username     : 'bob',
					passwordHash : '$2b$10$BzAkXcZ54JxhHTqCQcFn8.H6klY/G48t4jDBeTE2d2lZJk/.tvv0G',
					displayName  : 'Bob',
					emails       : [ { value: 'bob@biloxi.com' } ],
					meet_roles   : [ ]
				}
			]
		}
	},
	*/
	// This logger class will have the log function
	// called every time there is a room created or destroyed,
	// or peer created or destroyed. This would then be able
	// to log to a file or external service.
	/* StatusLogger          : class
	{
		constructor()
		{
			this._queue = new AwaitQueue();
		}

		// rooms: rooms object
		// peers: peers object
		// eslint-disable-next-line no-unused-vars
		async log({ rooms, peers })
		{
			this._queue.push(async () =>
			{
				// Do your logging in here, use queue to keep correct order

				// eslint-disable-next-line no-console
				console.log('Number of rooms: ', rooms.size);
				// eslint-disable-next-line no-console
				console.log('Number of peers: ', peers.size);
			})
				.catch((error) =>
				{
					// eslint-disable-next-line no-console
					console.log('error in log', error);
				});
		}
	}, */
	// This function will be called on successful login through oidc.
	// Use this function to map your oidc userinfo to the Peer object.
	// The roomId is equal to the room name.
	// See examples below.
	// Examples:
	/*
	// All authenticated users will be MODERATOR and AUTHENTICATED
	userMapping : async ({ peer, room, roomId, userinfo }) =>
	{
		peer.addRole(userRoles.MODERATOR);
		peer.addRole(userRoles.AUTHENTICATED);
	},
	// All authenticated users will be AUTHENTICATED,
	// and those with the moderator role set in the userinfo
	// will also be MODERATOR
	userMapping : async ({ peer, room, roomId, userinfo }) =>
	{
		if (
			Array.isArray(userinfo.meet_roles) &&
			userinfo.meet_roles.includes('moderator')
		)
		{
			peer.addRole(userRoles.MODERATOR);
		}

		if (
			Array.isArray(userinfo.meet_roles) &&
			userinfo.meet_roles.includes('meetingadmin')
		)
		{
			peer.addRole(userRoles.ADMIN);
		}

		peer.addRole(userRoles.AUTHENTICATED);
	},
	// First authenticated user will be moderator,
	// all others will be AUTHENTICATED
	userMapping : async ({ peer, room, roomId, userinfo }) =>
	{
		if (room)
		{
			const peers = room.getJoinedPeers();

			if (peers.some((_peer) => _peer.authenticated))
				peer.addRole(userRoles.AUTHENTICATED);
			else
			{
				peer.addRole(userRoles.MODERATOR);
				peer.addRole(userRoles.AUTHENTICATED);
			}
		}
	},
	// All authenticated users will be AUTHENTICATED,
	// and those with email ending with @example.com
	// will also be MODERATOR
	userMapping : async ({ peer, room, roomId, userinfo }) =>
	{
		if (userinfo.email && userinfo.email.endsWith('@example.com'))
		{
			peer.addRole(userRoles.MODERATOR);
		}

		peer.addRole(userRoles.AUTHENTICATED);
	},
	*/
	// eslint-disable-next-line no-unused-vars
	userMapping           : async ({ peer, room, roomId, userinfo }) =>
	{
		if (userinfo.picture != null)
		{
			if (!userinfo.picture.match(/^http/g))
			{
				peer.picture = `data:image/jpeg;base64, ${userinfo.picture}`;
			}
			else
			{
				peer.picture = userinfo.picture;
			}
		}
		if (userinfo['urn:oid:0.9.2342.19200300.100.1.60'] != null)
		{
			peer.picture = `data:image/jpeg;base64, ${userinfo['urn:oid:0.9.2342.19200300.100.1.60']}`;
		}

		if (userinfo.nickname != null)
		{
			peer.displayName = userinfo.nickname;
		}

		if (userinfo.name != null)
		{
			peer.displayName = userinfo.name;
		}

		if (userinfo.displayName != null)
		{
			peer.displayName = userinfo.displayName;
		}

		if (userinfo['urn:oid:2.16.840.1.113730.3.1.241'] != null)
		{
			peer.displayName = userinfo['urn:oid:2.16.840.1.113730.3.1.241'];
		}

		if (userinfo.email != null)
		{
			peer.email = userinfo.email;
		}
	},
	// All users have the role "NORMAL" by default. Other roles need to be
	// added in the "userMapping" function. The following accesses and
	// permissions are arrays of roles. Roles can be changed in userRoles.js
	//
	// Example:
	// [ userRoles.MODERATOR, userRoles.AUTHENTICATED ]
	// Mediasoup settings
	mediasoup            :
	{
		numWorkers : Object.keys(os.cpus()).length,
		// mediasoup Worker settings.
		worker     :
		{
			logLevel : 'warn',
			logTags  :
			[
				'info',
				'ice',
				'dtls',
				'rtp',
				'srtp',
				'rtcp'
			],
			rtcMinPort : 40000,
			rtcMaxPort : 49999
		},
		// mediasoup Router settings.
		router :
		{
			// Router media codecs.
			mediaCodecs :
			[
				{
					kind      : 'audio',
					mimeType  : 'audio/opus',
					clockRate : 48000,
					channels  : 2
				},
				{
					kind       : 'video',
					mimeType   : 'video/VP8',
					clockRate  : 90000,
					parameters :
					{
						'x-google-start-bitrate' : 1000
					}
				},
				{
					kind       : 'video',
					mimeType   : 'video/VP9',
					clockRate  : 90000,
					parameters :
					{
						'profile-id'             : 2,
						'x-google-start-bitrate' : 1000
					}
				},
				{
					kind       : 'video',
					mimeType   : 'video/h264',
					clockRate  : 90000,
					parameters :
					{
						'packetization-mode'      : 1,
						'profile-level-id'        : '4d0032',
						'level-asymmetry-allowed' : 1,
						'x-google-start-bitrate'  : 1000
					}
				},
				{
					kind       : 'video',
					mimeType   : 'video/h264',
					clockRate  : 90000,
					parameters :
					{
						'packetization-mode'      : 1,
						'profile-level-id'        : '42e01f',
						'level-asymmetry-allowed' : 1,
						'x-google-start-bitrate'  : 1000
					}
				}
			]
		},
		// mediasoup WebRtcTransport settings.
		webRtcTransport :
		{
			listenIps : getListenIps(),
			initialAvailableOutgoingBitrate : 1000000,
			minimumAvailableOutgoingBitrate : 600000,
			// Additional options that are not part of WebRtcTransportOptions.
			maxIncomingBitrate              : 1500000
		}
	}
};
