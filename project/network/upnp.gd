
var XML = preload('res://network/xml.gd')
var Http = preload('res://network/http.gd')
var discovery = preload('res://network/discovery.gdns').new()

enum STATE {
	READY,
	GET_DESCRIPTION,
	ADD_PORT_MAPPING,
	DISCOVERY,
	DONE,
}

var state = STATE.READY
var description_queue = []
var description_request = null
var add_port_mapping_request = null

const HTTPMU_HOST_ADDRESS = '239.255.255.250'
const HTTPMU_HOST_PORT = 1900

const HTTP_OK = '200 OK'
const DEFAULT_HTTP_PORT  = 80

const HTTP_URL_PREFIX = 'http://'

const DEVICE_UPNP = 'upnp:rootdevice'
const DEVICE_TYPE_1 = 'urn:schemas-upnp-org:device:InternetGatewayDevice:1'
const DEVICE_TYPE_2 = 'urn:schemas-upnp-org:device:WANDevice:1'
const DEVICE_TYPE_3 = 'urn:schemas-upnp-org:device:WANConnectionDevice:1'

const SERVICE_WANIP = 'urn:schemas-upnp-org:service:WANIPConnection:1'
const SERVICE_WANPPP = 'urn:schemas-upnp-org:service:WANPPPConnection:1'

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

func request_device_description(url):
	return Http.new(url.host, url.port, HTTPClient.METHOD_GET, url.path, [])

func parse_device_description(url, request):
	var xml = XML.new(request)

	# figure out base url
	var base_url = 'http://' + url.host + ':' + str(url.port)
	var base_url_node = xml.get_child_node(xml.root, 'URLBase', 0)
	if base_url_node and base_url_node.text:
		base_url = base_url_node.text

	var internet_gateway_device = null
	for node in xml.get_child_nodes(xml.root, 'device'):
		var device_type = xml.get_child_node(node, 'deviceType', 0)
		if device_type.text == DEVICE_TYPE_1:
			internet_gateway_device = node
	# failed to find internet_gateway_device
	if !internet_gateway_device:
		return null

	# get device list of internet_gateway_device
	var device_list = xml.get_child_node(internet_gateway_device, 'deviceList', 0)
	if !device_list:
		return null

	var wan_device = null
	for node in xml.get_child_nodes(device_list, 'device'):
		var device_type = xml.get_child_node(node, 'deviceType', 0)
		if device_type.text == DEVICE_TYPE_2:
			wan_device = node
	# failed to find wan_device
	if !wan_device:
		return null

	# get device list of wan_device
	device_list = xml.get_child_node(wan_device, 'deviceList', 0)
	if !device_list:
		return null

	var wan_connection_device = null
	for node in xml.get_child_nodes(device_list, 'device'):
		var device_type = xml.get_child_node(node, 'deviceType', 0)
		if device_type.text == DEVICE_TYPE_3:
			wan_connection_device = node
	# failed to find wan_connection_device
	if !wan_connection_device:
		return null

	# get service list of wan_connection_device
	var service_list = xml.get_child_node(wan_connection_device, 'serviceList', 0)
	if !service_list:
		return null

	var service = null
	for node in xml.get_child_nodes(service_list, 'service'):
		var service_type = xml.get_child_node(node, 'serviceType', 0)
		if service_type.text == SERVICE_WANIP or service_type.text == SERVICE_WANPPP:
			service = node
	# failed to find service
	if !service:
		return null

	var service_type = xml.get_child_node(service, 'serviceType', 0).text
	var control_url = xml.get_child_node(service, 'controlURL', 0).text
	if control_url.to_lower().find('http://') == -1:
		control_url = base_url + control_url

	return {
		service_type = service_type,
		control_url = control_url,
	}

func _add_port_mapping_params(external_port, protocol, local_port, local_ip, description):
	return PoolStringArray([
		'<NewRemoteHost></NewRemoteHost>',
		'<NewExternalPort>%s</NewExternalPort>' % external_port,
		'<NewProtocol>%s</NewProtocol>' % protocol,
		'<NewInternalPort>%s</NewInternalPort>' % local_port,
		'<NewInternalClient>%s</NewInternalClient>' % local_ip,
		'<NewEnabled>1</NewEnabled>',
		'<NewPortMappingDescription>%s</NewPortMappingDescription>' % description,
		'<NewLeaseDuration>604800</NewLeaseDuration>',
	]).join('\r\n')

func _soap_action(action_name, action_params, service_type):
	return PoolStringArray([
		'<?xml version=\"1.0\" encoding=\"utf-8\"?>',
		'<s:Envelope',
		'xmlns:s="http://schemas.xmlsoap.org/soap/envelope/"',
		's:encodingStyle="http://schemas.xmlsoap.org/soap/encoding/">',
		'<s:Body>',
		'<u:%s xmlns:u="%s">' % [action_name, service_type],
		action_params,
		'</u:%s>' % action_name,
		'</s:Body>',
		'</s:Envelope>',
	]).join('\r\n')

func _soap_headers(action_name, service_type, message_length):
	return [
		'SOAPACTION: %s#%s' % [ service_type, action_name, ],
		'CONTENT-TYPE: text/xml ; charset="utf-8"',
		'CONTENT-LENGTH: %s' % message_length,
	]
	
func _match_ip(local_ip, control_ip):
	var local = local_ip.split('.')[0]
	var control = control_ip.split('.')[0]
	return local == control

func request_add_port_mapping(local_port, device):
	var action_name = 'AddPortMapping'
	
	var service_type = device.service_type
	var url = parse_url(device.control_url)
	var local_ip = null
	for ip in discovery.ifaddrs():
		if _match_ip(ip, url.host):
			local_ip = ip
	
	var action_params = _add_port_mapping_params(local_port, 'UDP', local_port, local_ip, 'game server')
	var body = _soap_action(action_name, action_params, service_type)
	var headers = _soap_headers(action_name, service_type, body.length())
	
	return Http.new(url.host, url.port, HTTPClient.METHOD_POST, url.path, headers, body)

func add_port_mapping(local_port, delta):
	if state == STATE.READY:
		state = STATE.GET_DESCRIPTION
		broadcast_for_device(DEVICE_UPNP)

	elif state <= STATE.DISCOVERY:
		var response = discovery.poll()
		match state:
			STATE.GET_DESCRIPTION:
				if response:
					var url = get_describe_url(response[0])
					if url:
						description_queue.append(parse_url(url))

				if description_queue.size() > 0:
					var url = description_queue.front()
					if !description_request:
						description_request = request_device_description(url)
					var request = description_request.poll(delta)
					if request:
						description_request = null
						description_queue.pop_front()
						var upnp_device = parse_device_description(url, request)
						if upnp_device:
							state = STATE.ADD_PORT_MAPPING
							add_port_mapping_request = request_add_port_mapping(local_port, upnp_device)

			STATE.ADD_PORT_MAPPING:
				var request = add_port_mapping_request.poll(delta)
				if request and add_port_mapping_request.response_code == 200:
					state = STATE.DONE
					return true

	return false
