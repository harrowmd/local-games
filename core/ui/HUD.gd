extends CanvasLayer
class_name HUD

## Fear meter + acorn counter, always-on-screen during play.

@onready var fear_bar: ProgressBar = $Control/FearBar
@onready var acorn_label: Label = $Control/AcornLabel
@onready var toast_label: Label = $Control/ToastLabel
@onready var toast_timer: Timer = $ToastTimer


func _ready() -> void:
	GameManager.fear_changed.connect(_on_fear_changed)
	GameManager.acorns_changed.connect(_on_acorns_changed)
	toast_label.visible = false
	toast_timer.timeout.connect(func(): toast_label.visible = false)
	_on_fear_changed(GameManager.fear)
	var required: int = GameManager.town.acorns_required if GameManager.town else 1
	_on_acorns_changed(GameManager.acorns_collected, required)


func _on_fear_changed(value: float) -> void:
	fear_bar.value = value


func _on_acorns_changed(count: int, required: int) -> void:
	acorn_label.text = "Acorns: %d / %d" % [count, required]


func show_toast(text: String, duration: float = 2.5) -> void:
	toast_label.text = text
	toast_label.visible = true
	toast_timer.wait_time = duration
	toast_timer.start()
