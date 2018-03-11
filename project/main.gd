extends Control

const SERVER_PORT = 7777

onready var server = preload('res://network/discovery.gd').new()
onready var client = preload('res://network/discovery.gd').new()

func _ready():
	server.whatismyip.get()
	
func _process(delta):
	var result = server.whatismyip.poll()
	if result:
		print('my ip ', result, ' !!')

#const HTTPMU_HOST_ADDRESS = '239.255.255.250'
#const HTTPMU_HOST_PORT = 1900
#const SEARCH_REQUEST_STRING = """M-SEARCH * HTTP/1.1
#ST:UPnP:rootdevice
#MX: 3
#Man:"ssdp:discover"
#HOST: 239.255.255.250:1900
#
#"""
#
#func _ready():
#	client.client(HTTPMU_HOST_ADDRESS, HTTPMU_HOST_PORT, SEARCH_REQUEST_STRING)
#
#func _process(delta):
#	var pongs = client.poll()
#	if pongs:
#		print(pongs)

#func _client_pong(message, address):
#	print(['_client_pong', message, address])
#
#func _ready():
#	server.server(SERVER_PORT, "Hello")
#	client.client('255.255.255.255', SERVER_PORT, "Searching")
#
#func _process(delta):
#	server.poll()
#	var pongs = client.poll()
#	if pongs:
#		print(pongs)
