extends Node

var upnp = preload('res://network/upnp.gd').new()
var whatismyip = preload('res://network/whatismyip.gd').new()
var discovery = preload('res://network/discovery.gdns').new()

func server(port, message):
	return discovery.server(port, message)
	
func client(address, port, message):
	return discovery.broadcast(address, port, message)
	
func poll():
	return discovery.poll()
