extends Node

## Autoload singleton. Fetches live current weather from Open-Meteo
## (https://open-meteo.com) which needs no API key. Town-agnostic --
## callers pass whichever lat/lon they want.

signal weather_ready(data: Dictionary)
signal weather_failed()

var _http: HTTPRequest


func _ready() -> void:
	_http = HTTPRequest.new()
	add_child(_http)
	_http.request_completed.connect(_on_request_completed)


func fetch(lat: float, lon: float) -> void:
	var url := "https://api.open-meteo.com/v1/forecast?latitude=%s&longitude=%s&current_weather=true" % [lat, lon]
	var err := _http.request(url)
	if err != OK:
		weather_failed.emit()


func _on_request_completed(result: int, response_code: int, _headers: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or response_code != 200:
		weather_failed.emit()
		return
	var json := JSON.new()
	if json.parse(body.get_string_from_utf8()) != OK:
		weather_failed.emit()
		return
	var data: Dictionary = json.data
	var current: Dictionary = data.get("current_weather", {})
	if current.is_empty():
		weather_failed.emit()
		return
	weather_ready.emit(current)


## Simplified WMO weather-code -> condition bucket used to pick a photo.
static func condition_label(weathercode: int) -> String:
	if weathercode == 0:
		return "sunny"
	elif weathercode in [1, 2, 3, 45, 48]:
		return "cloudy"
	elif weathercode >= 51 and weathercode <= 67:
		return "rainy"
	elif weathercode >= 71 and weathercode <= 86:
		return "snowy"
	elif weathercode >= 95:
		return "rainy"
	return "cloudy"
