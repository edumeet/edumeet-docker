// The tracker for file sharing in meetings: the bittorrent-tracker server over WebSocket only.
//
// A shared file stays inside its room because only the room's participants know its info-hash.
// The stock tracker answers a scrape without an info-hash with the list of all of them, to
// anyone. This one answers it with an empty list.
//
// The stock tracker also stops with an exception on a scrape whose info_hash is neither a
// string nor a list. That gets the empty list too.
import { Server } from 'bittorrent-tracker';

class Tracker extends Server {
	_onScrape(params, cb) {
		// Not an error: the server's error answer needs an info-hash and throws without one.
		if (!Array.isArray(params.info_hash)) params.info_hash = [];

		super._onScrape(params, cb);
	}
}

// No HTTP or UDP tracker and no statistics page: the clients use WebSocket only.
const server = new Tracker({ http: false, udp: false, ws: true, stats: false, trustProxy: true, interval: 60000 });

server.on('error', (err) => console.error(`${new Date().toISOString()} ERROR: ${err.message}`));
server.on('warning', (err) => console.log(`${new Date().toISOString()} WARNING: ${err.message}`));
server.on('listening', () => console.log(`WebSocket tracker: ws://0.0.0.0:${server.ws.address().port}`));

server.listen(Number(process.env.PORT) || 8000, '0.0.0.0');
