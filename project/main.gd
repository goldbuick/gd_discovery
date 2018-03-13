extends Control

const SERVER_PORT = 7777
const SERVER_HANDSHAKE = 'game_server_834'

var server = preload('res://network/server.gd').new()
var client = preload('res://network/client.gd').new()

func _ready():
	server.connect('external_ip', self, '_server_external_ip')
	server.start(SERVER_PORT, SERVER_HANDSHAKE)
	
	client.connect('found_server', self, '_client_found_server')
	client.start(SERVER_HANDSHAKE)
	
func _process(delta):
	server.poll()
	client.poll()
	
func _client_found_server(ip):
	print('client found server ', ip)

func _server_external_ip(ip):
	print('external ip ', ip)
	
#func _process(delta):
#	server.server_poll()
#	if server.external_ip:
#		print('external ip ', server.external_ip)
#
#	var server_ip = client.client_poll()
#	if server_ip:
#		print('server_ip ', server_ip)
#
#	var success = server.upnp.add_port_mapping(SERVER_PORT)
#	if success:
#		print('port mapping added ', SERVER_PORT)
