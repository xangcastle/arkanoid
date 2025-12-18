extends StaticBody2D

enum Type { WHITE, ORANGE, CYAN, GREEN, RED, BLUE, PINK, YELLOW, SILVER, GOLD }
@export var type: Type = Type.WHITE

var hp = 1
var value = 50
@onready var sprite = $Sprite2D

const COLORS = {
    Type.WHITE: "res://assets/graphics/brick_white.png",
    Type.ORANGE: "res://assets/graphics/brick_orange.png",
    Type.CYAN: "res://assets/graphics/brick_cyan.png",
    Type.GREEN: "res://assets/graphics/brick_green.png",
    Type.RED: "res://assets/graphics/brick_red.png",
    Type.BLUE: "res://assets/graphics/brick_blue.png",
    Type.PINK: "res://assets/graphics/brick_pink.png",
    Type.YELLOW: "res://assets/graphics/brick_yellow.png",
    Type.SILVER: "res://assets/graphics/brick_silver.png",
    Type.GOLD: "res://assets/graphics/brick_gold.png"
}

const POINTS = {
    Type.WHITE: 50, Type.ORANGE: 60, Type.CYAN: 70, Type.GREEN: 80,
    Type.RED: 90, Type.BLUE: 100, Type.PINK: 110, Type.YELLOW: 120,
    Type.SILVER: 50, Type.GOLD: 0 
}

func _ready():
    setup_brick()

func setup_brick():
    if type == Type.SILVER:
        hp = 2 + int(GameManager.level / 8) # simplistic scaling
        value = 50 * GameManager.level
    elif type == Type.GOLD:
        hp = 999
        value = 0
    else:
        hp = 1
        value = POINTS.get(type, 50)
    
    var tex_path = COLORS.get(type)
    if tex_path:
        sprite.texture = load(tex_path)
        # Scale to match 32x16 grid (sprites are ~43x21)
        var tex_size = sprite.texture.get_size()
        sprite.scale = Vector2(32.0 / tex_size.x, 16.0 / tex_size.y)

func hit():
    if type == Type.GOLD:
        AudioManager.play("brick_hit_metal")
        return
        
    hp -= 1
    if hp <= 0:
        die()
    else:
        AudioManager.play("brick_hit_metal") # Silver brick hit sound

func die():
    AudioManager.play("brick_hit")
    GameManager.add_score(value)
    # Check for powerup drop
    if randf() < 0.1: # 10% chance
        spawn_powerup()
    queue_free()

func spawn_powerup():
    var main = get_tree().current_scene
    # We need a proper reference to PowerUp scene here, but for now we skip or load generic
    pass
