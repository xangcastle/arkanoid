extends Area2D

const SPEED = 600.0

func _process(delta):
    position.y -= SPEED * delta
    if position.y < 0:
        queue_free()

func _on_body_entered(body):
    if body.has_method("hit"):
        body.hit()
        AudioManager.play("laser") # Impact sound? Or just hit sound
        queue_free()
    elif body.name == "TopWall": # Wall
        queue_free()
