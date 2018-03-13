
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

const HTTP_OK = '200 OK'
const DEFAULT_HTTP_PORT  = 80

const HTTP_URL_PREFIX = 'http://'

func broadcast_for_device(device):
	var SEARCH_REQUEST_STRING = PoolStringArray([
		'M-SEARCH * HTTP/1.1',
		'HOST: 239.255.255.250:1900',
		'ST: ' + device,
		'MAN: "ssdp:discover"',
		'MX: 1',
		'',
	]).join('\r\n')
	discovery.broadcast(HTTPMU_HOST_ADDRESS, HTTPMU_HOST_PORT, SEARCH_REQUEST_STRING)

func add_port_mapping(port):
	if state == STATE.READY:
		state = STATE.BROADCAST
		broadcast_for_device('urn:schemas-upnp-org:device:InternetGatewayDevice:1')
		broadcast_for_device('urn:schemas-upnp-org:service:WANIPConnection:1')
		broadcast_for_device('urn:schemas-upnp-org:service:WANPPPConnection:1')
		broadcast_for_device('upnp:rootdevice')
		
	elif state <= STATE.DISCOVERY:
		var response = discovery.poll()
		if response:
			print(response[0])
	else:
		match state:
			STATE.DONE:
				return true
			
	return false
