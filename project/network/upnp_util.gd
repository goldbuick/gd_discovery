
static func parse_url(url):
	# http://192.168.86.1:5000/rootDesc.xml
	var parts = url.split('//')
	parts = Array(parts[1].split('/'))
	# host:port
	var host_port = parts.pop_front()
	host_port = host_port.split(':')
	var host = host_port[0]
	var port = int(host_port[1]) if host_port.size() > 1 else HTTP_PORT
	# /path
	var path = '/' + PoolStringArray(parts).join('/')
	return {
		host = host,
		port = port,
		path = path
	}

static func search_request(device_type):
  return PoolStringArray([
		'M-SEARCH * HTTP/1.1',
		'HOST: 239.255.255.250:1900',
		'ST: %s' % device_type,
		'MAN: "ssdp:discover"',
		'MX: 3',
		'',
  ]).join('\r\n')

static func add_port_mapping_params(external_port, protocol, local_port, local_ip, description):
	return PoolStringArray([
		'<NewRemoteHost></NewRemoteHost>',
		'<NewExternalPort>%s</NewExternalPort>' % external_port,
		'<NewProtocol>%s</NewProtocol>' % protocol,
		'<NewInternalPort>%s</NewInternalPort>' % local_port,
		'<NewInternalClient>%s</NewInternalClient>' % local_ip,
		'<NewEnabled>1</NewEnabled>',
		'<NewPortMappingDescription>%s</NewPortMappingDescription>' % description,
		'<NewLeaseDuration>604800</NewLeaseDuration>', # 1 week lease time
	]).join('\r\n')

static func soap_action(action_name, action_params, service_type):
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

static func soap_headers(action_name, service_type, message_length):
	return [
		'SOAPACTION: %s#%s' % [ service_type, action_name, ],
		'CONTENT-TYPE: text/xml ; charset="utf-8"',
		'CONTENT-LENGTH: %s' % message_length,
	]
