extends Node

## Autoload singleton holding run state for whichever town game is active.
## Town-agnostic: everything town-specific comes in via TownData/ProtagonistData.

signal fear_changed(value: float)
signal acorns_changed(count: int)
signal landmarks_progress_changed(correct_count: int, total: int)
signal landmark_answered(id: String, correct: bool)
signal game_over(won: bool)

var town: TownData
var protagonist: ProtagonistData
var fear: float = 0.0
var acorns_collected: int = 0
var total_landmarks: int = 0
var answered_landmarks: Dictionary = {}
var game_active: bool = false


func start_run(town_data: TownData, protagonist_data: ProtagonistData) -> void:
	town = town_data
	protagonist = protagonist_data
	fear = town.starting_fear
	acorns_collected = 0
	total_landmarks = 0
	answered_landmarks.clear()
	game_active = true
	fear_changed.emit(fear)
	acorns_changed.emit(acorns_collected)
	landmarks_progress_changed.emit(0, 0)


func set_total_landmarks(count: int) -> void:
	total_landmarks = count
	landmarks_progress_changed.emit(answered_landmarks.size(), total_landmarks)


func add_fear(amount: float) -> void:
	if not game_active:
		return
	fear = clamp(fear + amount, 0.0, 100.0)
	fear_changed.emit(fear)
	if fear >= 100.0:
		lose()


func lose() -> void:
	if not game_active:
		return
	game_active = false
	game_over.emit(false)


func collect_acorn() -> void:
	if not game_active:
		return
	acorns_collected += 1
	acorns_changed.emit(acorns_collected)


func spend_acorn() -> bool:
	if not game_active or acorns_collected <= 0:
		return false
	acorns_collected -= 1
	acorns_changed.emit(acorns_collected)
	return true


## Only correct answers stick -- a wrong answer doesn't lock a landmark
## out, so the player can walk back and try again later.
func mark_landmark_answered(id: String, correct: bool) -> void:
	if correct:
		if answered_landmarks.has(id):
			return
		answered_landmarks[id] = true
		landmark_answered.emit(id, true)
		add_fear(-town.fear_loss_per_correct)
		collect_acorn()
		landmarks_progress_changed.emit(answered_landmarks.size(), total_landmarks)
	else:
		landmark_answered.emit(id, false)
		add_fear(town.fear_gain_per_wrong)


func is_landmark_answered(id: String) -> bool:
	return answered_landmarks.has(id)


func can_go_home() -> bool:
	return total_landmarks > 0 and answered_landmarks.size() >= total_landmarks


func win() -> void:
	if not game_active:
		return
	game_active = false
	game_over.emit(true)
