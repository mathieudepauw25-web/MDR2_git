extends Node

var base_url: String = "http://127.0.0.1:3000"

func make_request(endpoint: String, method: int, data: String, callback: Callable) -> void:
	var http_request = HTTPRequest.new()
	add_child(http_request)
	
	http_request.request_completed.connect(func(result: int, response_code: int, resp_headers: PackedStringArray, body: PackedByteArray):
		callback.call(result, response_code, resp_headers, body)
		http_request.queue_free()
	)
	
	var url = base_url + endpoint
	var req_headers = ["Content-Type: application/json"]
	
	var error = http_request.request(url, req_headers, method, data)
	if error != OK:
		printerr("ApiManager Error: Failed to initiate request to ", url, " (Code: ", error, ")")
		http_request.queue_free()
