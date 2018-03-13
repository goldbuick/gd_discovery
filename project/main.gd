extends Control

const SERVER_PORT = 7777
const SERVER_HANDSHAKE = 'game_server_834'

var server = preload('res://network/server.gd').new()
#var client = preload('res://network/client.gd').new()

func _ready():
	server.connect('external_ip', self, '_server_external_ip')
	server.connect('port_forwarding', self, '_server_port_forwarding')
	server.start(SERVER_PORT, SERVER_HANDSHAKE)
	
#	client.connect('found_server', self, '_client_found_server')
#	client.start(SERVER_HANDSHAKE)
	
func _process(delta):
	server.poll(delta)
#	client.poll()
	
func _client_found_server(ip):
	print('client found server ', ip)

func _server_external_ip(ip):
	print('external ip ', ip)
	
func _server_port_forwarding(external_port):
	print('port forwarding ', external_port)
