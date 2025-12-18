extends Area2D

const SPEED = 600.0

func _ready():
    area_entered.connect(_on_area_entered)

func _process(delta):
    position.y -= SPEED * delta
    if position.y < 0:
        queue_free()

func _on_area_entered(area):
    if area.has_method("hit"):
        area.hit()
        # AudioManager.play("laser") # Enemy handles explosion sound
        queue_free()

func _on_body_entered(body):
    if body.has_method("hit"):
        body.hit()
        AudioManager.play("laser") # Impact sound? Or just hit sound
        queue_free()
    elif body.name == "TopWall": # Wall
        queue_free()
