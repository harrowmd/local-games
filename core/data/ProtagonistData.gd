extends Resource
class_name ProtagonistData

## The controllable creature/sprite for a town game. Swap this resource
## (and its texture) to reuse all core/ systems with a different mascot.

@export var creature_name: String = "Squirrel"
@export var sprite_texture: Texture2D
@export var sprite_scale: float = 1.0
@export var move_speed: float = 260.0
@export var friction: float = 600.0
@export var collision_radius: float = 28.0
