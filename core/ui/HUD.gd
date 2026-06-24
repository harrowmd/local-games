extends CanvasLayer
class_name HUD

## Fear meter, acorn (ammo) counter, and landmark quiz progress.

signal throw_pressed()

@onready var fear_bar: ProgressBar = $Control/FearBar
@onready var acorn_label: Label = $Control/AcornLabel
@onready var landmarks_label: Label = $Control/LandmarksLabel
@onready var toast_label: Label = $Control/BottomVBox/ToastLabel
@onready var toast_timer: Timer = $ToastTimer
@onready var throw_button: Button = $Control/BottomVBox/ThrowButton


func _ready() -> void:
	GameManager.fear_changed.connect(_on_fear_changed)
	GameManager.acorns_changed.connect(_on_acorns_changed)
	GameManager.landmarks_progress_changed.connect(_on_landmarks_progress_changed)
	toast_label.visible = false
	toast_timer.timeout.connect(func(): toast_label.visible = false)
	throw_button.pressed.connect(func(): throw_pressed.emit())
	throw_button.visible = false
	_on_fear_changed(GameManager.fear)
	_on_acorns_changed(GameManager.acorns_collected)
	_on_landmarks_progress_changed(GameManager.answered_landmarks.size(), GameManager.total_landmarks)


func set_throw_button_visible(value: bool) -> void:
	throw_button.visible = value


func _on_fear_changed(value: float) -> void:
	fear_bar.value = value


func _on_acorns_changed(count: int) -> void:
	acorn_label.text = "Acorns: %d" % count


func _on_landmarks_progress_changed(correct_count: int, total: int) -> void:
	landmarks_label.text = "Landmarks: %d / %d" % [correct_count, total]


func show_toast(text: String, duration: float = 2.5) -> void:
	toast_label.text = text
	toast_label.visible = true
	toast_timer.wait_time = duration
	toast_timer.start()
