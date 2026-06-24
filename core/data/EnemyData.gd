extends Resource
class_name EnemyData

## Optional predator config for a town (e.g. a fox chasing the squirrel).
## A town with `TownData.enemy_data == null` has no predator at all --
## this whole mechanic is opt-in per town.

@export var enemy_name: String = "Fox"
@export var sprite_texture: Texture2D
@export var speed: float = 80.0
@export var catch_radius: float = 40.0
@export var respawn_delay: float = 4.0
@export var spawn_delay: float = 10.0
@export var projectile_speed: float = 480.0
