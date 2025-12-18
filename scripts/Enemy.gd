extends Area2D

enum Type { KONERD, PYRADOK, TRI_SPHERE, OPOPO }
var type = Type.KONERD
var speed = 150.0
var direction = Vector2(0, 1)
var time_alive = 0.0

@onready var sprite = $Sprite2D

const TEXTURES = {
    Type.KONERD: "res://assets/graphics/enemy_cone_1.png",
    Type.PYRADOK: "res://assets/graphics/enemy_pyramid_1.png",
    Type.TRI_SPHERE: "res://assets/graphics/enemy_molecule_1.png",
    Type.OPOPO: "res://assets/graphics/enemy_cube_1.png" # Placeholder/Best fit
}

func _ready():
    var tex_path = TEXTURES.get(type)
    if tex_path:
        sprite.texture = load(tex_path)
    
    # Initial setup per type
    match type:
        Type.KONERD:
            speed = 150.0
            direction = Vector2(0.5, 1).normalized()
        Type.PYRADOK:
            speed = 100.0
            direction = Vector2(0, 1)
        Type.TRI_SPHERE:
            speed = 80.0
        Type.OPOPO:
            speed = 200.0
            direction = Vector2(randf_range(-0.5, 0.5), 1).normalized()

func _physics_process(delta):
    time_alive += delta
    
    match type:
        Type.KONERD:
            # Diagonal bounce
            position += direction * speed * delta
            if position.x < 16:
                direction.x = abs(direction.x)
            elif position.x > 432:
                direction.x = -abs(direction.x)
                
        Type.PYRADOK:
            # Zig-zag / Sine wave
            position.y += speed * delta
            position.x += cos(time_alive * 5.0) * 100.0 * delta 
            
        Type.TRI_SPHERE:
            # Pulsing size (visual only for now) + slow descent ?
            # Image says "pulsan cambiando su tamaño de colision"
            position.y += speed * delta
            var scale_factor = 1.0 + sin(time_alive * 3.0) * 0.2
            scale = Vector2(scale_factor, scale_factor)
            
        Type.OPOPO:
            # Erratic
            position += direction * speed * delta
            if randf() < 0.05: # Change dir
                direction = Vector2(randf_range(-1, 1), randf_range(0.2, 1)).normalized()
            # Bounce walls
            if position.x < 16: direction.x = abs(direction.x)
            if position.x > 432: direction.x = -abs(direction.x)
            
    if position.y > 600:
        queue_free()

func _on_body_entered(body):
    if body.is_in_group("Player"):
        # Enemy dies on impact with Vaus (User request)
        GameManager.add_score(100)
        AudioManager.play("explosion")
        queue_free()
    elif body.is_in_group("Balls"):
        # Ball hit enemy
        GameManager.add_score(100)
        AudioManager.play("explosion")
        queue_free()

func hit():
    # Laser hit
    GameManager.add_score(100)
    AudioManager.play("explosion")
    queue_free()
