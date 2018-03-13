
var server_port = 0
var discovery_port = 7173
var upnp = preload('res://network/upnp.gd').new()
var whatismyip = preload('res://network/whatismyip.gd').new()
var discovery = preload('res://network/discovery.gdns').new()

signal external_ip(ip)
signal port_forwarding(external_port)

func start(port, handshake):
	server_port = port
	return discovery.server(discovery_port, handshake)

func poll(delta):
	discovery.poll()

	var external_port = upnp.add_port_mapping(server_port, delta)
	if external_port:
		emit_signal('port_forwarding', external_port)
		
	var ip = whatismyip.request()
	if ip:
		emit_signal('external_ip', ip)
