/**
 * Edumeet App Configuration
 *
 * The configuration documentation is available also:
 * - in the app/README.md file in the source tree
 */

// eslint-disable-next-line
var config = {
	// If ability to log in is enabled.
	loginEnabled: true,

	// The development server listening port.
	developmentPort: 3443,

	// The production server listening port.
	productionPort: 443,

	// If the server component runs on a different host than the app you can specify the host name.
	serverHostname: '',

	// Number of videos to show based on speaker detection.
	lastN: 11,

	// Don't show the participant tile if the user has no video
	hideNonVideo: false,

	// The default video camera capture resolution.
	resolution: 'medium',

	// The default video camera capture framerate.
	frameRate: 30,

	// The default screen sharing resolution.
	screenSharingResolution: 'veryhigh',

	// The default screen sharing framerate.
	screenSharingFrameRate: 5,

	// Video aspect ratio.
	aspectRatio: 1.778,

	// Enable or disable simulcast for webcam video.
	simulcast: true,

	// Enable or disable simulcast for screen sharing video.
	simulcastSharing: false,

	// If set to true Local Recording feature will be enabled.
	localRecordingEnabled: false,

	// The Socket.io request timeout.
	requestTimeout: 20000,

	// The Socket.io request maximum retries.
	requestRetries: 3,

	// Auto gain control enabled.
	autoGainControl: true,

	// Echo cancellation enabled.
	echoCancellation: true,

	// Noise suppression enabled.
	noiseSuppression: true,

	// Automatically unmute speaking above noiseThreshold.
	voiceActivatedUnmute: false,

	// This is only for voiceActivatedUnmute and audio-indicator.
	noiseThreshold: -60,

	// The audio sample rate.
	sampleRate: 48000,

	// The audio channels count.
	channelCount: 1,

	// The audio sample size count.
	sampleSize: 16,

	// If OPUS FEC stereo be enabled.
	opusStereo: false,

	// If OPUS DTX should be enabled.
	opusDtx: true,

	// If OPUS FEC should be enabled.
	opusFec: true,

	// The OPUS packet time.
	opusPtime: 20,

	// The OPUS playback rate.
	opusMaxPlaybackRate: 48000,

	// The audio preset
	audioPreset: 'conference',

	// The audio presets.
	audioPresets: {
		'conference': {
			'name': 'Conference audio',
			'autoGainControl': true,
			'echoCancellation': true,
			'noiseSuppression': true,
			'voiceActivatedUnmute': false,
			'noiseThreshold': -60,
			'sampleRate': 48000,
			'channelCount': 1,
			'sampleSize': 16,
			'opusStereo': false,
			'opusDtx': true,
			'opusFec': true,
			'opusPtime': 20,
			'opusMaxPlaybackRate': 48000
		},
		'hifi': {
			'name': 'HiFi streaming',
			'autoGainControl': false,
			'echoCancellation': false,
			'noiseSuppression': false,
			'voiceActivatedUnmute': false,
			'noiseThreshold': -60,
			'sampleRate': 48000,
			'channelCount': 2,
			'sampleSize': 16,
			'opusStereo': true,
			'opusDtx': false,
			'opusFec': true,
			'opusPtime': 60,
			'opusMaxPlaybackRate': 48000
		}
	},

	// It sets the maximum number of participants in one room that can join unmuted.
	// The next participant will join automatically muted.
	// Set it to 0 to auto mute all.
	// Set it to negative (-1) to never automatically auto mute but use it with caution, 
	// full mesh audio strongly decrease room capacity!
	autoMuteThreshold: 4,

	// The default layout.
	defaultLayout: 'democratic',

	// If true, the media control buttons will be shown in separate control bar, not in the ME container.
	buttonControlBar: false,

	// The position of the notifications.
	notificationPosition: 'right',

	// It sets the notifications sounds.
	// Valid keys are: 'parkedPeer', 'parkedPeers', 'raisedHand', 
	// 'chatMessage', 'sendFile', 'newPeer' and 'default'.
	// Not defining a key is equivalent to using the default notification sound.
	// Setting 'play' to null disables the sound notification.
	notificationSounds: {
		'chatMessage': {
			'play': '/sounds/notify-chat.mp3'
		},
		'raisedHand': {
			'play': '/sounds/notify-hand.mp3'
		},
		'default': {
			'delay': 5000,
			'play': '/sounds/notify.mp3'
		}
	},

	// The title to show if the logo is not specified.
	title: 'edumeet',

	// The service & Support URL; if `null`, it will be not displayed on the about dialogs.
	supportUrl: 'https://support.example.com',

	// The privacy and data protection external URL or local HTML path.
	privacyUrl: 'privacy/privacy.html',

	// Client theme. Take a look at mui theme documentation.
	theme: {
		palette: {
			primary: {
				main: '#313131',
			}
		},
		// The page background image URL
		backgroundImage: 'images/background.jpg',
		appBarColor: '#313131', // AppBar background color
		// If not null, it shows the logo loaded from the specified URL, otherwise it shows the title.
		logo: 'images/logo.edumeet.svg',
		activeSpeakerBorder: '1px solid rgba(255, 255, 255, 1.0)',
		peerBackroundColor: 'rgba(49, 49, 49, 0.9)',
		peerShadow: '1px 5px 0px rgba(0, 0, 0, 0.2), 0px 2px 2px 0px rgba(0, 0, 0, 0.14), 0px 3px 1px -2px rgba(0, 0, 0, 0.12)',
		peerAvatar: 'images/buddy.svg',
		chatColor: 'rgba(224, 224, 224, 0.52)',
	},

	// Configuration for ObserveRTC
	// https://github.com/ObserveRTC/client-monitor-js#configurations
	observertc: {
		collectingPeriodInMs: 2000,
		statsExpirationTimeInMs: 60000,
	}
};
