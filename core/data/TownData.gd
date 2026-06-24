extends Resource
class_name TownData

## Per-town configuration. Each town game points one of these at its own
## assets/data; everything in core/ reads only through these fields.

@export var town_name: String = ""
@export var home_label: String = "Home"
@export_multiline var intro_text: String = ""

@export_group("Map")
@export var map_texture: Texture2D
@export var map_size: Vector2 = Vector2(1600, 1600)
@export var start_position: Vector2 = Vector2.ZERO
@export var home_position: Vector2 = Vector2.ZERO
@export var home_radius: float = 70.0
@export var landmark_data_path: String = ""
@export var icon_landmark_pin: Texture2D
@export var icon_acorn: Texture2D
@export var icon_home: Texture2D

@export_group("Weather")
@export var weather_latitude: float = 51.2335
@export var weather_longitude: float = -0.3303
@export var photo_sunny: Texture2D
@export var photo_cloudy: Texture2D
@export var photo_rainy: Texture2D
@export var photo_snowy: Texture2D
@export var photo_night: Texture2D
@export var photo_default: Texture2D

@export_group("Predator (optional)")
@export var enemy_data: EnemyData
@export var enemy_spawn_margin: float = 80.0

@export_group("Difficulty")
@export var fear_loss_per_correct: float = 12.0
@export var fear_gain_per_wrong: float = 18.0
@export var fear_passive_gain_per_sec: float = 0.4
@export var starting_fear: float = 20.0
