extends Control

func _process(_delta):
    if Input.is_action_just_pressed("fire") or Input.is_action_just_pressed("start"):
        GameManager.reset_game()
        get_tree().change_scene_to_file("res://scenes/core/Main.tscn")
