
enum STATE {
	READY,
	CONNECT,
	REQUEST,
	READING,
	BUFFER,
	TIMEOUT,
	DONE,
}

var http = null
var response_code = null
var response_buffer = null
var state = STATE.READY

var time = 0
var host
var port
var method
var path
var headers
var body

func _init(host, port, method, path, headers, body = ''):
	self.host = host
	self.port = port
	self.method = method
	self.path = path
	self.headers = headers
	self.body = body
	
func poll(delta = 0):
	if state > STATE.READY and state < STATE.DONE:
		http.poll()
		response_code = http.get_response_code()
		time += delta
		if time > 5:
			state = STATE.TIMEOUT

	match state:
		STATE.READY:
			http = HTTPClient.new()
			state = STATE.CONNECT
			var err = http.connect_to_host(host, port)
			assert(err == OK)
			
		STATE.CONNECT:
			if http.get_status() == HTTPClient.STATUS_CONNECTED:
				state = STATE.REQUEST
				var err = http.request(method, path, headers, body)
				assert(err == OK)

		STATE.REQUEST:
			if http.get_status() != HTTPClient.STATUS_REQUESTING and http.has_response():
				state = STATE.READING
				response_buffer = PoolByteArray()
					
		STATE.READING:
			var chunk = http.read_response_body_chunk()
			if chunk.size() > 0:
				response_buffer += chunk
			if http.get_status() != HTTPClient.STATUS_BODY:
				state = STATE.BUFFER
				
		STATE.BUFFER:
			state = STATE.DONE
			http.close()
			http = null
			return response_buffer.get_string_from_ascii().strip_edges()
			
	return null	