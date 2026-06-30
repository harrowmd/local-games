extends Control
class_name OpeningScreen

@export var town: TownData
@export var protagonist: ProtagonistData
@export var next_scene: PackedScene

@onready var photo_rect: TextureRect = $Photo
@onready var top_vbox: VBoxContainer = $TopVBox
@onready var title_label: Label = $TopVBox/TitleLabel
@onready var datetime_label: Label = $TopVBox/DateTimeLabel
@onready var weather_label: Label = $TopVBox/WeatherLabel
@onready var bottom_bar: HBoxContainer = $BottomBar
@onready var sprite_rect: TextureRect = $BottomBar/SpriteRect
@onready var exit_button: Button = $BottomBar/ExitButton
@onready var start_button: Button = $BottomBar/StartButton
@onready var clock_timer: Timer = $ClockTimer

var _geograph_loaded := false

const H_MARGIN := 24.0
const V_MARGIN := 30.0
const BAR_HEIGHT := 160.0  # SpriteRect minimum height drives the bar


func _ready() -> void:
	title_label.text = town.town_name
	sprite_rect.texture = protagonist.sprite_texture
	photo_rect.texture = town.photo_default
	weather_label.text = "Checking local weather..."
	_update_datetime()
	clock_timer.timeout.connect(_update_datetime)
	WeatherService.weather_ready.connect(_on_weather_ready)
	WeatherService.weather_failed.connect(_on_weather_failed)
	WeatherService.fetch(town.weather_latitude, town.weather_longitude)
	PhotoService.photo_ready.connect(_on_photo_ready)
	PhotoService.photo_failed.connect(_on_photo_failed)
	PhotoService.fetch(true)
	exit_button.pressed.connect(func(): get_tree().quit())
	start_button.pressed.connect(_on_start_pressed)
	get_viewport().size_changed.connect(_do_layout)
	await get_tree().process_frame
	_do_layout()


func _do_layout() -> void:
	var vp := get_viewport().get_visible_rect().size
	photo_rect.position = Vector2.ZERO
	photo_rect.size = vp
	top_vbox.position = Vector2(H_MARGIN, V_MARGIN)
	top_vbox.size = Vector2(vp.x - H_MARGIN * 2, 0)
	bottom_bar.position = Vector2(H_MARGIN, vp.y - BAR_HEIGHT - V_MARGIN)
	bottom_bar.size = Vector2(vp.x - H_MARGIN * 2, BAR_HEIGHT)


func _update_datetime() -> void:
	var dt := Time.get_datetime_dict_from_system()
	datetime_label.text = "%04d-%02d-%02d   %02d:%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute]


func _is_night(dt: Dictionary) -> bool:
	return dt.hour < 6 or dt.hour >= 21


func _on_photo_ready(texture: Texture2D) -> void:
	photo_rect.texture = texture
	_do_layout()
	_geograph_loaded = true


func _on_photo_failed() -> void:
	pass


func _on_weather_ready(data: Dictionary) -> void:
	var temp = data.get("temperature", null)
	var code := int(data.get("weathercode", 0))
	var condition := WeatherService.condition_label(code)
	if _is_night(Time.get_datetime_dict_from_system()):
		condition = "night"
	weather_label.text = "%s, %s°C" % [condition.capitalize(), str(temp)]
	if not _geograph_loaded:
		photo_rect.texture = _photo_for(condition)


func _on_weather_failed() -> void:
	weather_label.text = "Weather unavailable"
	if not _geograph_loaded:
		photo_rect.texture = town.photo_night if _is_night(Time.get_datetime_dict_from_system()) else town.photo_default


func _photo_for(condition: String) -> Texture2D:
	match condition:
		"sunny":
			return town.photo_sunny
		"cloudy":
			return town.photo_cloudy
		"rainy":
			return town.photo_rainy
		"snowy":
			return town.photo_snowy
		"night":
			return town.photo_night
		_:
			return town.photo_default


func _on_start_pressed() -> void:
	get_tree().change_scene_to_packed(next_scene)
