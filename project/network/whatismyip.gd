
var http = preload('res://network/http.gd').new()

const HEADERS = [
	"User-Agent: Discovery/1.0 (Godot)",
	"Accept: */*"
]

func request():
	return http.request('icanhazip.com', 80, HTTPClient.METHOD_GET, '/', HEADERS)
