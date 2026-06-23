extends Area2D
class_name AcornPickup

## A single acorn on the trail home. Collecting one nudges the player
## toward the acorn requirement needed to unlock the home delivery.

@onready var icon: Sprite2D = $Icon


func setup(pos: Vector2, icon_texture: Texture2D = null) -> void:
	position = pos
	if icon and icon_texture:
		icon.texture = icon_texture


func _on_body_entered(body: Node) -> void:
	if not body is PlayerController:
		return
	GameManager.collect_acorn()
	queue_free()


func _ready() -> void:
	body_entered.connect(_on_body_entered)
