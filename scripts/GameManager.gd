extends Node

signal score_changed(new_score)
signal lives_changed(new_lives)
signal level_completed
signal game_over

var score = 0
var high_score = 50000
var lives = 3
var level = 1
var max_levels = 36 # approx

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS

func add_score(points):
    score += points
    if score > high_score:
        high_score = score
    score_changed.emit(score)

func lose_life():
    lives -= 1
    lives_changed.emit(lives)
    if lives < 0:
        game_over.emit()
    else:
        # Respawn logic usually handled by Main
        pass

func add_life():
    lives += 1
    lives_changed.emit(lives)

func reset_game():
    score = 0
    lives = 3
    level = 1
    score_changed.emit(score)
    lives_changed.emit(lives)

func next_level():
    level += 1
    level_completed.emit()
