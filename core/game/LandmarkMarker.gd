extends Area2D
class_name LandmarkMarker

## A touchable landmark on the map. Holds its own clue data (loaded from
## the town's landmarks.json) and fires `reached` the first time the
## player enters it, as long as it hasn't already been answered.

signal reached(data: Dictionary)

@onready var label: Label = $Label
@onready var icon: Sprite2D = $Icon

var data: Dictionary = {}


func setup(landmark_data: Dictionary, icon_texture: Texture2D = null) -> void:
	data = landmark_data
	position = Vector2(data.get("x", 0.0), data.get("y", 0.0))
	if label:
		label.text = data.get("name", "")
	if icon and icon_texture:
		icon.texture = icon_texture


func _on_body_entered(body: Node) -> void:
	if not body is PlayerController:
		return
	if GameManager.is_landmark_answered(data.get("id", "")):
		return
	reached.emit(data)


func _ready() -> void:
	body_entered.connect(_on_body_entered)
