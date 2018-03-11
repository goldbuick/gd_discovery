extends Node

enum STATE {
	READY,
	CONNECT,
	REQUEST,
	READING,
	BUFFER,
	DONE,
}

var http = null
var read_buffer = null
var state = STATE.READY

func get():
	if state > STATE.READY && state < STATE.DONE:
		http.poll()

	match state:
		STATE.READY:
			http = HTTPClient.new()
			state = STATE.CONNECT
			var err = http.connect_to_host('icanhazip.com', 80)
			assert(err == OK)
			
		STATE.CONNECT:
			if http.get_status() == HTTPClient.STATUS_CONNECTED:
				state = STATE.REQUEST
				var headers = [
					"User-Agent: Discovery/1.0 (Godot)",
					"Accept: */*"
				]
				var err = http.request(HTTPClient.METHOD_GET, "/", headers)
				assert(err == OK)

		STATE.REQUEST:
			if http.get_status() != HTTPClient.STATUS_REQUESTING and http.has_response():
				state = STATE.READING
				read_buffer = PoolByteArray()
					
		STATE.READING:
			var chunk = http.read_response_body_chunk()
			if chunk.size() > 0:
				read_buffer += chunk
			if http.get_status() != HTTPClient.STATUS_BODY:
				state = STATE.BUFFER
				
		STATE.BUFFER:
			state = STATE.DONE
			http.close()
			http = null
			return read_buffer.get_string_from_ascii().strip_edges()
			
	return null