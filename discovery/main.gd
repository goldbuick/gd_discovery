extends Control

onready var discovery = preload('res://bin/discovery.gdns').new()

const HTTPMU_HOST_ADDRESS = '239.255.255.250'
const HTTPMU_HOST_PORT = 1900
const SEARCH_REQUEST_STRING = """M-SEARCH * HTTP/1.1
ST:UPnP:rootdevice
MX: 3
Man:"ssdp:discover"
HOST: 239.255.255.250:1900

"""

func _ready():
	var result = discovery.ping(HTTPMU_HOST_ADDRESS, HTTPMU_HOST_PORT, SEARCH_REQUEST_STRING)
	print(['ping', result])

func _process(delta):
	var pongs = discovery.pongs()
	if pongs:
		print(pongs)

