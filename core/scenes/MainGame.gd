extends Node2D
class_name MainGame

## The playable map for any town. Reads everything from GameManager.town
## (set by OpeningScreen) or, if run standalone in the editor, bootstraps
## itself from the exported `town`/`protagonist` fields.

const LandmarkMarkerScene := preload("res://core/game/LandmarkMarker.tscn")
const AcornPickupScene := preload("res://core/game/AcornPickup.tscn")

@export var town: TownData
@export var protagonist: ProtagonistData

@onready var map_background: Sprite2D = $MapBackground
@onready var player: PlayerController = $Player
@onready var landmarks_root: Node2D = $LandmarksRoot
@onready var acorns_root: Node2D = $AcornsRoot
@onready var home_marker: HomeMarker = $HomeMarker
@onready var hud: HUD = $HUD
@onready var clue_popup: CluePopup = $CluePopup
@onready var game_over_layer: CanvasLayer = $GameOverLayer
@onready var result_label: Label = $GameOverLayer/Panel/Margin/VBox/ResultLabel
@onready var restart_button: Button = $GameOverLayer/Panel/Margin/VBox/RestartButton
@onready var ambient_timer: Timer = $AmbientFearTimer


func _ready() -> void:
	if GameManager.town == null and town != null:
		GameManager.start_run(town, protagonist)
	var t: TownData = GameManager.town
	var p: ProtagonistData = GameManager.protagonist

	map_background.texture = t.map_texture
	map_background.position = Vector2.ZERO
	map_background.centered = false

	player.position = t.start_position
	player.move_speed = p.move_speed
	player.friction = p.friction
	player.map_bounds = Rect2(Vector2.ZERO, t.map_size)
	if p.sprite_texture:
		($Player/Sprite as Sprite2D).texture = p.sprite_texture
		($Player/Sprite as Sprite2D).scale = Vector2(p.sprite_scale, p.sprite_scale)

	home_marker.setup(t.home_position, t.home_label, t.icon_home)
	home_marker.arrived.connect(_on_home_arrived)

	game_over_layer.visible = false
	clue_popup.closed.connect(_on_clue_closed)

	_load_landmarks_and_acorns(t)

	GameManager.game_over.connect(_on_game_over)
	restart_button.pressed.connect(_on_restart_pressed)
	ambient_timer.wait_time = 1.0
	ambient_timer.timeout.connect(_on_ambient_tick)
	ambient_timer.start()


func _load_landmarks_and_acorns(t: TownData) -> void:
	if t.landmark_data_path.is_empty():
		return
	var f := FileAccess.open(t.landmark_data_path, FileAccess.READ)
	if f == null:
		push_warning("Could not open landmark data: " + t.landmark_data_path)
		return
	var json := JSON.new()
	if json.parse(f.get_as_text()) != OK:
		push_warning("Could not parse landmark data: " + t.landmark_data_path)
		return
	var data: Dictionary = json.data

	for landmark_data in data.get("landmarks", []):
		var marker: LandmarkMarker = LandmarkMarkerScene.instantiate()
		landmarks_root.add_child(marker)
		marker.setup(landmark_data, t.icon_landmark_pin)
		marker.reached.connect(_on_landmark_reached)

	for pos in data.get("trail_acorns", []):
		var acorn: AcornPickup = AcornPickupScene.instantiate()
		acorns_root.add_child(acorn)
		acorn.setup(Vector2(pos.get("x", 0.0), pos.get("y", 0.0)), t.icon_acorn)


func _on_landmark_reached(data: Dictionary) -> void:
	player.movement_enabled = false
	clue_popup.show_clue(data)


func _on_clue_closed() -> void:
	player.movement_enabled = true


func _on_home_arrived(ready_to_win: bool) -> void:
	if not ready_to_win:
		var remaining: int = GameManager.town.acorns_required - GameManager.acorns_collected
		hud.show_toast("Not yet -- find %d more acorns before heading home." % remaining)


func _on_ambient_tick() -> void:
	GameManager.add_fear(GameManager.town.fear_passive_gain_per_sec)


func _on_game_over(won: bool) -> void:
	player.movement_enabled = false
	ambient_timer.stop()
	game_over_layer.visible = true
	if won:
		result_label.text = "%s made it home to %s!" % [GameManager.protagonist.creature_name, GameManager.town.home_label]
	else:
		result_label.text = "%s got too scared and ran off. Try again!" % GameManager.protagonist.creature_name


func _on_restart_pressed() -> void:
	var t := GameManager.town
	var p := GameManager.protagonist
	GameManager.start_run(t, p)
	get_tree().reload_current_scene()
