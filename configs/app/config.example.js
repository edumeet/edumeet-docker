// eslint-disable-next-line
var config =
{
	loginEnabled     : false,
	developmentPort  : 3443,
	productionPort   : 443,
	// FQDN
	// l'hostname pubblico del tuo server MM (senza https://)
	// ad esempio mm.iorestoacasa.work
	multipartyServer : 'CHANGEME',
	turnServers      : [
		{
			urls : [
				// inserisci l'URL del tuo server
				// ad esempio:
				// 'turn:mm.iorestoacasa.work:3478?transport=tcp'
				'turn:CHANGEME:3478?transport=tcp'
			],
			// username e password che specifichi qui
			// dovranno essere gli stessi che inserisci
			// in coturn.conf
			username   : 'CHANGEME',
			credential : 'CHANGEME'
		}
	],
	/**
	 * If defaultResolution is set, it will override user settings when joining:
	 * low ~ 320x240
	 * medium ~ 640x480
	 * high ~ 1280x720
	 * veryhigh ~ 1920x1080
	 * ultra ~ 3840x2560
	 **/
	defaultResolution  : 'medium',
	// Enable or disable simulcast for webcam video
	simulcast          : true,
	// Enable or disable simulcast for screen sharing video
	simulcastSharing   : false,
	// Simulcast encoding layers and levels
	simulcastEncodings :
	[
		{ scaleResolutionDownBy: 4 },
		{ scaleResolutionDownBy: 2 },
		{ scaleResolutionDownBy: 1 }
	],
	// Socket.io request timeout	
	requestTimeout   : 10000,
	transportOptions :
	{
		tcp : true
	},
	lastN       : 4,
	mobileLastN : 1,
	background  : 'images/background.jpg',
	// Add file and uncomment for adding logo to appbar
	 logo       : 'images/iorestoacasa-logo.svg',
	title       : 'IoRestoACasa.work',
	theme       :
	{
		palette :
		{
			primary :
			{
				main : '#313131'
			}
		},
		overrides :
		{
			MuiAppBar :
			{
				colorPrimary :
				{
					backgroundColor : '#313131'
				}
			},
			MuiFab :
			{
				primary :
				{
					backgroundColor : '#5F9B2D',
					'&:hover'       :
					{
						backgroundColor : '#518029'
					}
				}
			},
			MuiBadge :
			{
				colorPrimary :
				{
					backgroundColor : '#5F9B2D',
					'&:hover'       :
					{
						backgroundColor : '#518029'
					}
				}
			}
		},
		typography :
		{
			useNextVariants : true
		}
	}
};
