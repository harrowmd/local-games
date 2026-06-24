extends Area2D
class_name AcornProjectile

## A thrown acorn. Travels in a straight line and stuns a FoxEnemy on
## contact, then disappears (whether it hits or flies off harmlessly).

signal hit_fox()

@export var max_distance: float = 1000.0

var _velocity: Vector2 = Vector2.ZERO
var _traveled: float = 0.0

@onready var icon: Sprite2D = $Icon


func setup(start_pos: Vector2, direction: Vector2, speed: float, icon_texture: Texture2D = null) -> void:
	position = start_pos
	_velocity = direction.normalized() * speed
	rotation = direction.angle()
	if icon and icon_texture:
		icon.texture = icon_texture


func _physics_process(delta: float) -> void:
	var step: Vector2 = _velocity * delta
	position += step
	_traveled += step.length()
	if _traveled >= max_distance:
		queue_free()


func _on_body_entered(body: Node) -> void:
	if body is FoxEnemy:
		hit_fox.emit()
		queue_free()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
