extends Control

const SERVER_PORT = 7777
const SERVER_HANDSHAKE = 'game_server_834'

onready var server = preload('res://network/discovery.gd').new()
onready var client = preload('res://network/discovery.gd').new()

func _ready():
	server.server(SERVER_PORT, SERVER_HANDSHAKE)
	client.client(SERVER_PORT, SERVER_HANDSHAKE)
	
func _process(delta):
	server.server_poll()
	if server.external_ip:
		print('external ip ', server.external_ip)

	var server_ip = client.client_poll()
	if server_ip:
		print('server_ip ', server_ip)
#
#	var success = server.upnp.add_port_mapping(SERVER_PORT)
#	if success:
#		print('port mapping added ', SERVER_PORT)
