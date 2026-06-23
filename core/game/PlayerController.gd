extends CharacterBody2D
class_name PlayerController

## Generic swipe/drag-to-move controller. Works with touch (mobile) and
## mouse (desktop testing). Town-agnostic -- speed/friction/bounds are
## injected by MainGame from TownData/ProtagonistData.

@export var move_speed: float = 260.0
@export var friction: float = 600.0
var map_bounds: Rect2 = Rect2(Vector2.ZERO, Vector2(1600, 1600))
var movement_enabled: bool = true

var _dragging: bool = false
var _drag_vector: Vector2 = Vector2.ZERO


func _unhandled_input(event: InputEvent) -> void:
	if not movement_enabled:
		return
	if event is InputEventScreenTouch:
		_dragging = event.pressed
		if not event.pressed:
			_drag_vector = Vector2.ZERO
	elif event is InputEventScreenDrag:
		_drag_vector = event.relative
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		_dragging = event.pressed
		if not event.pressed:
			_drag_vector = Vector2.ZERO
	elif event is InputEventMouseMotion and _dragging:
		_drag_vector = event.relative


func _physics_process(delta: float) -> void:
	if movement_enabled and _dragging and _drag_vector.length() > 0.5:
		var target: Vector2 = _drag_vector.normalized() * move_speed
		velocity = velocity.move_toward(target, friction * delta * 2.0)
		_drag_vector = Vector2.ZERO
	else:
		velocity = velocity.move_toward(Vector2.ZERO, friction * delta)
	move_and_slide()
	position.x = clamp(position.x, map_bounds.position.x, map_bounds.position.x + map_bounds.size.x)
	position.y = clamp(position.y, map_bounds.position.y, map_bounds.position.y + map_bounds.size.y)
