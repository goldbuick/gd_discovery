
var Http = preload('res://network/http.gd')
var discovery = preload('res://network/discovery.gdns').new()

enum STATE {
	READY,
	GET_DESCRIPTION,
	DISCOVERY,
	DONE,
}

var state = STATE.READY
var get_description_queue = []
var get_description_request = null

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
		'MX: 3',
		'',
	]).join('\r\n')
	discovery.broadcast(HTTPMU_HOST_ADDRESS, HTTPMU_HOST_PORT, SEARCH_REQUEST_STRING)
	
func get_describe_url(response):
	var begin = response.find(HTTP_OK)
	if begin == -1:
		return null
	begin = response.find(HTTP_URL_PREFIX)
	if begin == -1:
		return null
	var end = response.find('\r', begin)
	if end == -1:
		return null
	return response.substr(begin, end-begin)
	
func parse_url(url):
	# http://192.168.86.1:5000/rootDesc.xml
	var parts = url.split('//')
	parts = Array(parts[1].split('/'))
	# host:port
	var host_port = parts.pop_front()
	host_port = host_port.split(':')
	var host = host_port[0]
	var port = int(host_port[1]) if host_port.size() > 1 else 80
	# /path
	var path = '/' + PoolStringArray(parts).join('/')
	return {
		host = host,
		port = port,
		path = path
	}
	
func xml_read_until_end(parser, node_name):
	var result = parser.read()
	if result == ERR_FILE_EOF:
		return true
	if parser.get_node_type() == XMLParser.NODE_ELEMENT_END and parser.get_node_name() == node_name:
		return true
	return false
	
func parse_device_description(url, request):
	var base_url = 'http://' + url.host + ':' + str(url.port)
	
	var parser = XMLParser.new()
	parser.open_buffer(request.to_ascii())
	while parser.read() != ERR_FILE_EOF:
		if parser.get_node_type() == XMLParser.NODE_ELEMENT:
			match parser.get_node_name():
				'URLBase':
					parser.read()
					print(parser.get_node_data())
				'device':
					while xml_read_until_end(parser, 'device'):
						if parser.get_node_type() == XMLParser.NODE_ELEMENT:
							print(parser.get_node_name())


func add_port_mapping(port, delta):
	if state == STATE.READY:
		state = STATE.GET_DESCRIPTION
		broadcast_for_device('upnp:rootdevice')
		broadcast_for_device('urn:schemas-upnp-org:device:WANDevice:1')
		broadcast_for_device('urn:schemas-upnp-org:device:WANConnectionDevice:1')
		broadcast_for_device('urn:schemas-upnp-org:device:InternetGatewayDevice:1')
		
	elif state <= STATE.DISCOVERY:
		var response = discovery.poll()
		match state:
			STATE.GET_DESCRIPTION:
				if response:
					var url = get_describe_url(response[0])
					if url:
						get_description_queue.append(parse_url(url))
						
				if get_description_queue.size() > 0:
					var url = get_description_queue[0]
					if !get_description_request:
						get_description_request = Http.new()
					var request = get_description_request.request(url.host, url.port, HTTPClient.METHOD_GET, url.path, [], delta)
					if request:
						var device = parse_device_description(url, request)
		
	else:
		match state:
			STATE.DONE:
				return true
			
	return false
