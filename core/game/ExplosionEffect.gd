extends Node2D
class_name ExplosionEffect

## Generic burst effect, town-agnostic. Spawn it at a world position and
## forget about it -- it animates itself out and frees itself. Used for
## the fox getting hit and the squirrel getting caught.

@onready var sprite: Sprite2D = $Sprite


func _ready() -> void:
	sprite.scale = Vector2(0.2, 0.2)
	sprite.modulate.a = 1.0
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "scale", Vector2(1.4, 1.4), 0.35).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(sprite, "modulate:a", 0.0, 0.4)
	tween.finished.connect(queue_free)
