extends Node

var discovery = preload('res://network/discovery.gdns').new()

func server(port, message):
	var result = discovery.server(port, message)
	print('server ', result)
	
func client(address, port, message):
	var result = discovery.broadcast(address, port, message)
	print('client ', result)
	
func poll():
	return discovery.poll()
