
var server_port = 0
var discovery_port = 7173
var upnp = preload('res://network/upnp.gd').new()
var whatismyip = preload('res://network/whatismyip.gd').new()
var discovery = preload('res://network/discovery.gdns').new()

signal external_ip(ip)
signal external_port(port)

func start(port, handshake):
	server_port = port
	return discovery.server(discovery_port, handshake)

func poll(delta):
	discovery.poll()

	var port = upnp.add_port_mapping(server_port, delta)
	if port:
		emit_signal('external_port', port)

	var ip = whatismyip.poll()
	if ip:
		emit_signal('external_ip', ip)
