extends Control

signal warp_finished

func _ready():
    $AnimationPlayer.play("warp_effect")
    AudioManager.play("warp") # Placeholder sound
    
func _on_animation_finished(anim_name):
    warp_finished.emit()
    queue_free()
