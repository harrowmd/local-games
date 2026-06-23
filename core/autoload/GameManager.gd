extends Node

## Autoload singleton holding run state for whichever town game is active.
## Town-agnostic: everything town-specific comes in via TownData/ProtagonistData.

signal fear_changed(value: float)
signal acorns_changed(count: int, required: int)
signal landmark_answered(id: String, correct: bool)
signal game_over(won: bool)

var town: TownData
var protagonist: ProtagonistData
var fear: float = 0.0
var acorns_collected: int = 0
var answered_landmarks: Dictionary = {}
var game_active: bool = false


func start_run(town_data: TownData, protagonist_data: ProtagonistData) -> void:
	town = town_data
	protagonist = protagonist_data
	fear = town.starting_fear
	acorns_collected = 0
	answered_landmarks.clear()
	game_active = true
	fear_changed.emit(fear)
	acorns_changed.emit(acorns_collected, town.acorns_required)


func add_fear(amount: float) -> void:
	if not game_active:
		return
	fear = clamp(fear + amount, 0.0, 100.0)
	fear_changed.emit(fear)
	if fear >= 100.0:
		game_active = false
		game_over.emit(false)


func collect_acorn() -> void:
	if not game_active:
		return
	acorns_collected += 1
	acorns_changed.emit(acorns_collected, town.acorns_required)


func mark_landmark_answered(id: String, correct: bool) -> void:
	if answered_landmarks.has(id):
		return
	answered_landmarks[id] = correct
	landmark_answered.emit(id, correct)
	if correct:
		add_fear(-town.fear_loss_per_correct)
		collect_acorn()
	else:
		add_fear(town.fear_gain_per_wrong)


func is_landmark_answered(id: String) -> bool:
	return answered_landmarks.has(id)


func can_go_home() -> bool:
	return acorns_collected >= town.acorns_required


func win() -> void:
	if not game_active:
		return
	game_active = false
	game_over.emit(true)
