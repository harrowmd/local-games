extends Area2D
class_name HomeMarker

## The destination. Entering it either wins the run (enough acorns
## collected) or asks the player to keep exploring.

signal arrived(ready_to_win: bool)

@onready var icon: Sprite2D = $Icon
@onready var label: Label = $Label

var _triggered_recently: bool = false


func setup(pos: Vector2, home_label: String, icon_texture: Texture2D = null) -> void:
	position = pos
	if label:
		label.text = home_label
	if icon and icon_texture:
		icon.texture = icon_texture


func _on_body_entered(body: Node) -> void:
	if not body is PlayerController or _triggered_recently:
		return
	_triggered_recently = true
	var ready_to_win := GameManager.can_go_home()
	arrived.emit(ready_to_win)
	if ready_to_win:
		GameManager.win()


func _on_body_exited(_body: Node) -> void:
	_triggered_recently = false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
