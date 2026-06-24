extends CharacterBody2D
class_name FoxEnemy

## Generic chase predator. Pursues `target` directly at `data.speed`.
## Catching the player emits `caught_player`; MainGame decides the
## consequence and despawns/respawns it. Getting hit by an
## AcornProjectile is also handled by MainGame, which removes this
## node entirely (see MainGame._on_projectile_hit_fox).

signal caught_player()

var data: EnemyData
var target: Node2D
var map_bounds: Rect2 = Rect2(Vector2.ZERO, Vector2(1600, 1600))

var _catch_cooldown: float = 0.0

@onready var sprite: Sprite2D = $Sprite
@onready var catch_shape: CollisionShape2D = $CatchArea/Collision


func setup(enemy_data: EnemyData, chase_target: Node2D, spawn_pos: Vector2) -> void:
	data = enemy_data
	target = chase_target
	position = spawn_pos
	if sprite and data.sprite_texture:
		sprite.texture = data.sprite_texture
	if catch_shape.shape is CircleShape2D:
		(catch_shape.shape as CircleShape2D).radius = data.catch_radius


func _physics_process(delta: float) -> void:
	if data == null:
		return
	if _catch_cooldown > 0.0:
		_catch_cooldown -= delta
	if target:
		var to_target: Vector2 = target.global_position - global_position
		if to_target.length() > 1.0:
			velocity = to_target.normalized() * data.speed
	move_and_slide()
	position.x = clamp(position.x, map_bounds.position.x, map_bounds.position.x + map_bounds.size.x)
	position.y = clamp(position.y, map_bounds.position.y, map_bounds.position.y + map_bounds.size.y)


func _on_catch_area_body_entered(body: Node) -> void:
	if _catch_cooldown > 0.0:
		return
	if body is PlayerController:
		_catch_cooldown = 1.0
		caught_player.emit()


func _ready() -> void:
	$CatchArea.body_entered.connect(_on_catch_area_body_entered)
