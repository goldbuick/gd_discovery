extends Control

const SERVER_PORT = 7777

onready var server = preload('res://network/discovery.gd').new()
onready var client = preload('res://network/discovery.gd').new()

#func _ready():
#	server.server(SERVER_PORT, "Hello")
#	client.client('255.255.255.255', SERVER_PORT, "Searching")
	
func _process(delta):
#	server.poll()
#	var pongs = client.poll()
#	if pongs:
#		print(pongs)

	var result = server.whatismyip.get()
	if result:
		print('my ip ', result, ' !!')

	var success = server.upnp.add_port_mapping(SERVER_PORT)
	if success:
		print('port mapping added ', SERVER_PORT)
