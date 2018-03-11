extends Node

var upnp = preload('res://network/upnp.gd').new()
var whatismyip = preload('res://network/whatismyip.gd').new()
var discovery = preload('res://network/discovery.gdns').new()

var external_ip = ''
var server_port = 0
var match_handshake = ''

func server(port, handshake):
	server_port = port
	return discovery.server(port, handshake)
	
func server_poll():
	discovery.poll()
	external_ip = whatismyip.get()
	
func client(port, handshake):
	match_handshake = handshake
	return discovery.broadcast('255.255.255.255', port, handshake)

func client_poll():
	var pong = discovery.poll()

	if pong and pong.size() == 2 and pong[0] == match_handshake:
		return pong[1]

	return null