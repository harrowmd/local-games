extends Control
class_name BriefingScreen

@export var town: TownData
@export var protagonist: ProtagonistData
@export var next_scene: PackedScene

@onready var photo_rect: TextureRect = $Photo
@onready var top_vbox: VBoxContainer = $TopVBox
@onready var title_label: Label = $TopVBox/TitleLabel
@onready var intro_label: Label = $TopVBox/IntroLabel
@onready var bottom_bar: HBoxContainer = $BottomBar
@onready var exit_btn: Button = $BottomBar/ExitButton
@onready var sprite_rect: TextureRect = $BottomBar/SpriteRect
@onready var start_btn: Button = $BottomBar/StartGameButton

const H_MARGIN := 32.0
const V_MARGIN := 40.0
const BAR_HEIGHT := 160.0

var _geograph_loaded := false


func _ready() -> void:
	title_label.text = town.town_name
	intro_label.text = town.intro_text
	sprite_rect.texture = protagonist.sprite_texture
	photo_rect.texture = town.photo_default
	PhotoService.photo_ready.connect(_on_photo_ready)
	PhotoService.photo_failed.connect(_on_photo_failed)
	PhotoService.fetch()
	exit_btn.pressed.connect(func(): get_tree().quit())
	start_btn.pressed.connect(_on_start_pressed)
	get_viewport().size_changed.connect(_do_layout)
	await get_tree().process_frame
	_do_layout()


func _do_layout() -> void:
	var vp := get_viewport().get_visible_rect().size
	photo_rect.position = Vector2.ZERO
	photo_rect.size = vp
	top_vbox.position = Vector2(H_MARGIN, V_MARGIN)
	top_vbox.size = Vector2(vp.x - H_MARGIN * 2, 0)
	bottom_bar.position = Vector2(H_MARGIN, vp.y - BAR_HEIGHT - V_MARGIN)
	bottom_bar.size = Vector2(vp.x - H_MARGIN * 2, BAR_HEIGHT)


func _on_photo_ready(texture: Texture2D) -> void:
	photo_rect.texture = texture
	_do_layout()
	_geograph_loaded = true


func _on_photo_failed() -> void:
	pass


func _on_start_pressed() -> void:
	GameManager.start_run(town, protagonist)
	get_tree().change_scene_to_packed(next_scene)
