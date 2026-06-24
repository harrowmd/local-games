extends Control
class_name OpeningScreen

## Splash screen shown before play starts. Generic across towns -- each
## game's own thin scene sets `town`, `protagonist`, and `next_scene`.
## Shows today's date/time, live local weather (via WeatherService), a
## matching placeholder photo, and the protagonist sprite.

@export var town: TownData
@export var protagonist: ProtagonistData
@export var next_scene: PackedScene

@onready var photo_rect: TextureRect = $Photo
@onready var title_label: Label = $Overlay/VBox/TitleLabel
@onready var datetime_label: Label = $Overlay/VBox/DateTimeLabel
@onready var weather_label: Label = $Overlay/VBox/WeatherLabel
@onready var intro_label: Label = $Overlay/VBox/IntroLabel
@onready var sprite_rect: TextureRect = $Overlay/VBox/SpriteRect
@onready var start_button: Button = $Overlay/VBox/StartButton
@onready var clock_timer: Timer = $ClockTimer


func _ready() -> void:
	title_label.text = town.town_name
	intro_label.text = town.intro_text
	sprite_rect.texture = protagonist.sprite_texture
	photo_rect.texture = town.photo_default
	weather_label.text = "Checking local weather..."
	_update_datetime()
	clock_timer.timeout.connect(_update_datetime)
	WeatherService.weather_ready.connect(_on_weather_ready)
	WeatherService.weather_failed.connect(_on_weather_failed)
	WeatherService.fetch(town.weather_latitude, town.weather_longitude)
	start_button.pressed.connect(_on_start_pressed)


func _update_datetime() -> void:
	var dt := Time.get_datetime_dict_from_system()
	datetime_label.text = "%04d-%02d-%02d   %02d:%02d" % [dt.year, dt.month, dt.day, dt.hour, dt.minute]


func _is_night(dt: Dictionary) -> bool:
	return dt.hour < 6 or dt.hour >= 21


func _on_weather_ready(data: Dictionary) -> void:
	var temp = data.get("temperature", null)
	var code := int(data.get("weathercode", 0))
	var condition := WeatherService.condition_label(code)
	if _is_night(Time.get_datetime_dict_from_system()):
		condition = "night"
	weather_label.text = "%s, %s°C" % [condition.capitalize(), str(temp)]
	photo_rect.texture = _photo_for(condition)


func _on_weather_failed() -> void:
	weather_label.text = "Weather unavailable"
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
	GameManager.start_run(town, protagonist)
	get_tree().change_scene_to_packed(next_scene)
