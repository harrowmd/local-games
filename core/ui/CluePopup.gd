extends CanvasLayer
class_name CluePopup

## Modal quiz shown when the player reaches an unanswered landmark.
## Pauses the tree, lets the player pick an answer, reveals the fact,
## then resumes on "Continue".

signal closed()

@onready var name_label: Label = $Dim/Panel/Margin/VBox/NameLabel
@onready var question_label: Label = $Dim/Panel/Margin/VBox/QuestionLabel
@onready var choices_container: VBoxContainer = $Dim/Panel/Margin/VBox/ChoicesContainer
@onready var fact_label: Label = $Dim/Panel/Margin/VBox/FactLabel
@onready var ok_button: Button = $Dim/Panel/Margin/VBox/OkButton

var _data: Dictionary = {}


func _ready() -> void:
	visible = false
	ok_button.pressed.connect(_on_ok_pressed)
	ok_button.visible = false
	fact_label.visible = false


func show_clue(data: Dictionary) -> void:
	_data = data
	name_label.text = data.get("name", "")
	question_label.text = data.get("question", "")
	fact_label.visible = false
	ok_button.visible = false
	for c in choices_container.get_children():
		c.queue_free()
	var choices: Array = data.get("choices", [])
	for i in range(choices.size()):
		var b := Button.new()
		b.text = choices[i]
		b.add_theme_font_size_override("font_size", 29)
		b.pressed.connect(_on_choice_pressed.bind(i))
		choices_container.add_child(b)
	visible = true
	get_tree().paused = true


func _on_choice_pressed(index: int) -> void:
	var correct: bool = index == int(_data.get("correct_index", -1))
	for c in choices_container.get_children():
		c.disabled = true
	fact_label.text = ("Correct! " if correct else "Not quite. ") + str(_data.get("fact", ""))
	fact_label.visible = true
	ok_button.visible = true
	GameManager.mark_landmark_answered(_data.get("id", ""), correct)


func _on_ok_pressed() -> void:
	visible = false
	get_tree().paused = false
	closed.emit()
