extends Node2D
class_name MainGame

## The playable map for any town. Reads everything from GameManager.town
## (set by OpeningScreen) or, if run standalone in the editor, bootstraps
## itself from the exported `town`/`protagonist` fields.

const LandmarkMarkerScene := preload("res://core/game/LandmarkMarker.tscn")
const AcornPickupScene := preload("res://core/game/AcornPickup.tscn")
const FoxEnemyScene := preload("res://core/game/FoxEnemy.tscn")
const AcornProjectileScene := preload("res://core/game/AcornProjectile.tscn")
const ExplosionEffectScene := preload("res://core/game/ExplosionEffect.tscn")

@export var town: TownData
@export var protagonist: ProtagonistData

@onready var map_background: Sprite2D = $MapBackground
@onready var player: PlayerController = $Player
@onready var landmarks_root: Node2D = $LandmarksRoot
@onready var acorns_root: Node2D = $AcornsRoot
@onready var enemies_root: Node2D = $EnemiesRoot
@onready var projectiles_root: Node2D = $ProjectilesRoot
@onready var home_marker: HomeMarker = $HomeMarker
@onready var hud: HUD = $HUD
@onready var clue_popup: CluePopup = $CluePopup
@onready var game_over_layer: CanvasLayer = $GameOverLayer
@onready var result_label: Label = $GameOverLayer/Panel/Margin/VBox/ResultLabel
@onready var restart_button: Button = $GameOverLayer/Panel/Margin/VBox/RestartButton
@onready var exit_button: Button = $GameOverLayer/Panel/Margin/VBox/ExitButton
@onready var ambient_timer: Timer = $AmbientFearTimer
@onready var fox_spawn_timer: Timer = $FoxSpawnTimer

var fox: FoxEnemy = null


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
	exit_button.pressed.connect(func(): get_tree().quit())
	ambient_timer.wait_time = 1.0
	ambient_timer.timeout.connect(_on_ambient_tick)
	ambient_timer.start()

	hud.throw_pressed.connect(_on_throw_pressed)
	if t.enemy_data:
		fox_spawn_timer.wait_time = t.enemy_data.spawn_delay
		fox_spawn_timer.one_shot = true
		fox_spawn_timer.timeout.connect(_spawn_fox)
		fox_spawn_timer.start()


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
	var landmark_list: Array = data.get("landmarks", [])
	GameManager.set_total_landmarks(landmark_list.size())

	for landmark_data in landmark_list:
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
		var remaining: int = GameManager.total_landmarks - GameManager.answered_landmarks.size()
		hud.show_toast("Not yet -- answer %d more landmark question(s) correctly first." % remaining)


func _on_ambient_tick() -> void:
	GameManager.add_fear(GameManager.town.fear_passive_gain_per_sec)


func _on_game_over(won: bool) -> void:
	player.movement_enabled = false
	ambient_timer.stop()
	game_over_layer.visible = true
	if won:
		result_label.text = "%s made it home to %s!" % [GameManager.protagonist.creature_name, GameManager.town.home_label]
	else:
		result_label.text = "%s didn't make it home this time. Try again!" % GameManager.protagonist.creature_name


func _random_perimeter_position(t: TownData) -> Vector2:
	var m: float = t.enemy_spawn_margin
	var w: float = t.map_size.x
	var h: float = t.map_size.y
	match randi() % 4:
		0:
			return Vector2(randf_range(m, w - m), m)
		1:
			return Vector2(randf_range(m, w - m), h - m)
		2:
			return Vector2(m, randf_range(m, h - m))
		_:
			return Vector2(w - m, randf_range(m, h - m))


func _spawn_fox() -> void:
	if not GameManager.game_active:
		return
	var t: TownData = GameManager.town
	fox = FoxEnemyScene.instantiate()
	enemies_root.add_child(fox)
	fox.map_bounds = Rect2(Vector2.ZERO, t.map_size)
	fox.setup(t.enemy_data, player, _random_perimeter_position(t))
	fox.caught_player.connect(_on_fox_caught_player)
	hud.set_throw_button_visible(true)


func _remove_fox() -> void:
	if fox and is_instance_valid(fox):
		fox.queue_free()
	fox = null
	hud.set_throw_button_visible(false)


func _schedule_fox_respawn(delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	_spawn_fox()


func _on_throw_pressed() -> void:
	if fox == null or not is_instance_valid(fox):
		return
	if not GameManager.spend_acorn():
		hud.show_toast("No acorns left to throw!")
		return
	var direction: Vector2 = fox.global_position - player.global_position
	if direction.length() < 0.01:
		direction = Vector2.RIGHT
	var projectile: AcornProjectile = AcornProjectileScene.instantiate()
	projectiles_root.add_child(projectile)
	projectile.setup(player.global_position, direction, GameManager.town.enemy_data.projectile_speed, GameManager.town.icon_acorn)
	projectile.hit_fox.connect(_on_projectile_hit_fox)


func _spawn_explosion(at_position: Vector2) -> void:
	var fx: ExplosionEffect = ExplosionEffectScene.instantiate()
	projectiles_root.add_child(fx)
	fx.global_position = at_position


func _on_projectile_hit_fox() -> void:
	if fox and is_instance_valid(fox):
		var t: TownData = GameManager.town
		_spawn_explosion(fox.global_position)
		_remove_fox()
		hud.show_toast("Fox driven off!")
		_schedule_fox_respawn(t.enemy_data.respawn_delay)


func _on_fox_caught_player() -> void:
	_spawn_explosion(player.global_position)
	_remove_fox()
	GameManager.lose()


func _on_restart_pressed() -> void:
	var t := GameManager.town
	var p := GameManager.protagonist
	GameManager.start_run(t, p)
	get_tree().reload_current_scene()
