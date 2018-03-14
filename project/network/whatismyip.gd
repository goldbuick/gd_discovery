
const HEADERS = [
	"User-Agent: Discovery/1.0 (Godot)",
	"Accept: */*"
]

var http = preload('res://network/http.gd').new('icanhazip.com', 80, HTTPClient.METHOD_GET, '/', HEADERS)

func poll():
	return http.poll()