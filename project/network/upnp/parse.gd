
var XML = preload('res://network/upnp/xml.gd')

const DEVICE_TYPE_1 = 'urn:schemas-upnp-org:device:InternetGatewayDevice:1'
const DEVICE_TYPE_2 = 'urn:schemas-upnp-org:device:WANDevice:1'
const DEVICE_TYPE_3 = 'urn:schemas-upnp-org:device:WANConnectionDevice:1'

const SERVICE_WANIP = 'urn:schemas-upnp-org:service:WANIPConnection:1'
const SERVICE_WANPPP = 'urn:schemas-upnp-org:service:WANPPPConnection:1'

const HTTP_OK = '200 OK'
const HTTP_URL_PREFIX = 'http://'

func describe_url(response):
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

func url(url):
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
	
func device_description(url, request):
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
	