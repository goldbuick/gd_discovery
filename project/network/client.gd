
var client_handshake = ''
var discovery_port = 7173
var discovery = preload('res://network/discovery.gdns').new()

signal found_server(ip)

func start(handshake):
	client_handshake = handshake
	return discovery.broadcast('255.255.255.255', discovery_port, handshake)

func poll():
	var pong = discovery.poll()
	if pong and pong[0] == client_handshake:
		emit_signal('found_server', pong[1])
