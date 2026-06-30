extends Node

## Autoload singleton. Fetches a daily Geograph photo of the Dorking area.
## No API key required — uses the public Geograph syndicator + photo API.
## Rotates through 5 location pools by day-of-year for variety.
## Caches today's photo to user:// so it only downloads once per day.

signal photo_ready(texture: Texture2D)
signal photo_failed()

const SYNDICATOR_URL = "https://api.geograph.org.uk/syndicator.php?key=test&location=%s&per_page=16"
const PHOTO_INFO_URL  = "https://api.geograph.org.uk/api/photo/%d?output=json&key=test"
const CACHE_META_FILE = "user://geograph_cache.json"
const CACHE_IMG_FILE  = "user://geograph_photo.jpg"

# 5 Dorking-area locations to rotate through for daily variety
const LOCATIONS = [
	"51.2335,-0.3303",  # town centre / High Street
	"51.2503,-0.3094",  # Box Hill
	"51.2260,-0.3280",  # Deepdene
	"51.2335,-0.3450",  # Dorking West / Westcott
	"51.2170,-0.3350",  # North Holmwood
]

var _http_feed: HTTPRequest
var _http_info: HTTPRequest
var _http_img:  HTTPRequest
var _photo_ids: Array = []
var _target_id: int = 0
var _force_fresh: bool = false


func _ready() -> void:
	_http_feed = HTTPRequest.new()
	add_child(_http_feed)
	_http_feed.request_completed.connect(_on_feed_done)

	_http_info = HTTPRequest.new()
	add_child(_http_info)
	_http_info.request_completed.connect(_on_info_done)

	_http_img = HTTPRequest.new()
	add_child(_http_img)
	_http_img.request_completed.connect(_on_img_done)


func fetch(force_fresh: bool = false) -> void:
	_force_fresh = force_fresh
	var today := Time.get_date_string_from_system()

	# Return cached photo if not forcing a fresh fetch
	if not force_fresh and FileAccess.file_exists(CACHE_META_FILE) and FileAccess.file_exists(CACHE_IMG_FILE):
		var f := FileAccess.open(CACHE_META_FILE, FileAccess.READ)
		var meta = JSON.parse_string(f.get_as_text())
		f.close()
		if meta is Dictionary and meta.get("date") == today:
			_emit_cached()
			return

	# Pick a random location when forcing fresh, otherwise use today's deterministic slot
	var loc: String
	if force_fresh:
		loc = LOCATIONS[randi() % LOCATIONS.size()]
	else:
		var dt := Time.get_datetime_dict_from_system()
		var day_of_year := _day_of_year(dt.year, dt.month, dt.day)
		loc = LOCATIONS[day_of_year % LOCATIONS.size()]
	_http_feed.request(SYNDICATOR_URL % loc)


func _on_feed_done(result: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		photo_failed.emit()
		return

	var text := body.get_string_from_utf8()
	var regex := RegEx.new()
	regex.compile(r'geograph\.org\.uk/photo/(\d+)')
	_photo_ids.clear()
	for m in regex.search_all(text):
		var id := int(m.get_string(1))
		if id > 0 and id not in _photo_ids:
			_photo_ids.append(id)

	if _photo_ids.is_empty():
		photo_failed.emit()
		return

	var idx: int
	if _force_fresh:
		idx = randi() % _photo_ids.size()
	else:
		var dt := Time.get_datetime_dict_from_system()
		var day_of_year := _day_of_year(dt.year, dt.month, dt.day)
		idx = (day_of_year / LOCATIONS.size()) % _photo_ids.size()
	_target_id = _photo_ids[idx]
	_http_info.request(PHOTO_INFO_URL % _target_id)


func _on_info_done(result: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200:
		photo_failed.emit()
		return

	var info = JSON.parse_string(body.get_string_from_utf8())
	if not info is Dictionary or not info.has("imgserver") or not info.has("image"):
		photo_failed.emit()
		return

	var img_url: String = info["imgserver"] + info["image"]
	_http_img.request(img_url)


func _on_img_done(result: int, code: int, _h: PackedStringArray, body: PackedByteArray) -> void:
	if result != HTTPRequest.RESULT_SUCCESS or code != 200 or body.is_empty():
		photo_failed.emit()
		return

	var img := Image.new()
	if img.load_jpg_from_buffer(body) != OK:
		photo_failed.emit()
		return

	# Cache image bytes and today's date
	var f := FileAccess.open(CACHE_IMG_FILE, FileAccess.WRITE)
	if f:
		f.store_buffer(body)
		f.close()
	var m := FileAccess.open(CACHE_META_FILE, FileAccess.WRITE)
	if m:
		m.store_string(JSON.stringify({"date": Time.get_date_string_from_system()}))
		m.close()

	photo_ready.emit(ImageTexture.create_from_image(img))


func _emit_cached() -> void:
	var f := FileAccess.open(CACHE_IMG_FILE, FileAccess.READ)
	if not f:
		photo_failed.emit()
		return
	var data := f.get_buffer(f.get_length())
	f.close()
	var img := Image.new()
	if img.load_jpg_from_buffer(data) != OK:
		photo_failed.emit()
		return
	photo_ready.emit(ImageTexture.create_from_image(img))


static func _day_of_year(y: int, m: int, d: int) -> int:
	var days_in_month := [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31]
	if (y % 4 == 0 and y % 100 != 0) or y % 400 == 0:
		days_in_month[2] = 29
	var total := 0
	for i in range(1, m):
		total += days_in_month[i]
	return total + d
