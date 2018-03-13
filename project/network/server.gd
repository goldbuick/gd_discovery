
var server_port = 0
var discovery_port = 7173
var upnp = preload('res://network/upnp.gd').new()
var whatismyip = preload('res://network/whatismyip.gd').new()
var discovery = preload('res://network/discovery.gdns').new()

signal external_ip(ip)
signal port_forwarding(enabled, external_port)

func start(port, handshake):
	server_port = port
	return discovery.server(discovery_port, handshake)

func poll():
	discovery.poll()
	var ip = whatismyip.request()
	if ip:
		emit_signal('external_ip', ip)