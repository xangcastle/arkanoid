extends Control

@onready var anim = $AnimationPlayer

func _ready():
    # Start the intro sequence
    anim.play("intro_sequence")
    AudioManager.play("intro_music")

func _process(_delta):
    if Input.is_action_just_pressed("fire") or Input.is_action_just_pressed("start"):
        # Skip intro
        start_game()

func start_game():
    get_tree().change_scene_to_file("res://scenes/core/Main.tscn")

func _on_animation_finished(anim_name):
    if anim_name == "intro_sequence":
        start_game()
