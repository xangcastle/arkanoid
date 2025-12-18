extends Area2D

const SPEED = 100.0

func _physics_process(delta):
    position.y += SPEED * delta
    
    # Simple bounce off walls logic (pseudo)
    if position.x < 24 or position.x > 424:
         # Flip direction if we had horizontal movement
         pass
         
    if position.y > 600:
        queue_free()

func _on_body_entered(body):
    if body.name == "Vaus":
        body.queue_free() # Kill player
        GameManager.lose_life()
        queue_free()
    elif body.name == "Ball":
        GameManager.add_score(100)
        # Play explosion sound
        queue_free()

func hit():
    # Called by Laser
    GameManager.add_score(100)
    queue_free()
