
var Http = preload('res://network/http.gd')
var Message = preload('res://network/upnp/message.gd')
var parse = preload('res://network/upnp/parse.gd').new()
var discovery = preload('res://network/discovery.gdns').new()

enum STATE {
	READY,
	GET_DESCRIPTION,
	ADD_PORT_MAPPING,
	DISCOVERY,
	DONE,
}

var state = STATE.READY
var external_port = 0
var description_queue = []
var description_request = null
var add_port_mapping_request = null

const HTTPMU_HOST_ADDRESS = '239.255.255.250'
const HTTPMU_HOST_PORT = 1900

func broadcast_for_device(device_type):
	var SEARCH_REQUEST_STRING = Message.search_request(device_type)
	discovery.broadcast(HTTPMU_HOST_ADDRESS, HTTPMU_HOST_PORT, SEARCH_REQUEST_STRING)

func request_device_description(url):
	return Http.new(url.host, url.port, HTTPClient.METHOD_GET, url.path, [])

func _match_ip(local_ip, control_ip):
	var local = local_ip.split('.')[0]
	var control = control_ip.split('.')[0]
	return local == control

func request_add_port_mapping(local_port, device):
	var action_name = 'AddPortMapping'

	var service_type = device.service_type
	var url = parse.url(device.control_url)
	var local_ip = null
	for ip in discovery.ifaddrs():
		if _match_ip(ip, url.host):
			local_ip = ip

	external_port = 27015 + randi() % 2000
	var action_params = Message.add_port_mapping_params(external_port, 'UDP', local_port, local_ip, 'game server')
	var body = Message.soap_action(action_name, action_params, service_type)
	var headers = Message.soap_headers(action_name, service_type, body.length())

	return Http.new(url.host, url.port, HTTPClient.METHOD_POST, url.path, headers, body)

func add_port_mapping(local_port, delta):
	if state == STATE.READY:
		state = STATE.GET_DESCRIPTION
		broadcast_for_device('upnp:rootdevice')

	elif state <= STATE.DISCOVERY:
		var response = discovery.poll()
		match state:
			STATE.GET_DESCRIPTION:
				if response:
					var url = parse.describe_url(response[0])
					if url:
						description_queue.append(parse.url(url))

				if description_queue.size() > 0:
					var url = description_queue.front()
					if !description_request:
						description_request = request_device_description(url)
					var request = description_request.poll(delta)
					if request:
						description_request = null
						description_queue.pop_front()
						var upnp_device = parse.device_description(url, request)
						if upnp_device:
							state = STATE.ADD_PORT_MAPPING
							add_port_mapping_request = request_add_port_mapping(local_port, upnp_device)

			STATE.ADD_PORT_MAPPING:
				var request = add_port_mapping_request.poll(delta)
				if request and add_port_mapping_request.response_code == 200:
					state = STATE.DONE
					return external_port

	return null
