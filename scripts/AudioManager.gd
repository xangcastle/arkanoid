extends Node

var sounds = {}
const AUDIO_PATH = "res://assets/audio/"

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    load_sound("paddle_hit", "paddle_hit.wav")
    load_sound("brick_hit", "brick_hit.wav")
    load_sound("brick_hit_metal", "brick_hit_metal.wav")
    load_sound("laser", "laser.wav")
    load_sound("explosion", "explosion.wav")
    load_sound("powerup", "powerup.wav")
    load_sound("life", "life.wav")
    load_sound("game_over", "game_over.wav")
    load_sound("game_start", "game_start.wav")

func load_sound(name, file):
    var path = AUDIO_PATH + file
    if FileAccess.file_exists(path):
        sounds[name] = load(path)
    else:
        print("Audio file missing: ", path)

func play(name):
    if sounds.has(name):
        var player = AudioStreamPlayer.new()
        player.stream = sounds[name]
        # Auto-free when finished
        player.finished.connect(player.queue_free)
        add_child(player)
        player.play()
    else:
        print("Sound not found: ", name)
