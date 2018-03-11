extends Node

# this will use discovery to find your router
# and then add a port forwarding address to your computer

var discovery = preload('res://network/discovery.gdns').new()

enum STATE {
	READY,
	BROADCAST,
	DISCOVERY,
	DONE,
}

var state = STATE.READY

const HTTPMU_HOST_ADDRESS = '239.255.255.250'
const HTTPMU_HOST_PORT = 1900
const SEARCH_REQUEST_STRING = """M-SEARCH * HTTP/1.1
ST:UPnP:rootdevice
MX: 3
Man:"ssdp:discover"
HOST: 239.255.255.250:1900

"""

const HTTP_OK = '200 OK'
const DEFAULT_HTTP_PORT  = 80


func add_port_mapping(port):
	if state == STATE.READY:
		state = STATE.BROADCAST
		discovery.broadcast(HTTPMU_HOST_ADDRESS, HTTPMU_HOST_PORT, SEARCH_REQUEST_STRING)
		
	elif state <= STATE.DISCOVERY:
		var pongs = discovery.poll()
		if pongs:
			print(pongs)
	else:
		match state:
			STATE.DONE:
				return true
			
	return false
