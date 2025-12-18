extends Area2D

enum Type { S, L, C, E, D, B, P }
var type = Type.S

const SPEEDS = 100.0

@onready var sprite = $Sprite2D

const TEXTURES = {
    Type.S: "res://assets/graphics/powerup_slow_1.png",
    Type.L: "res://assets/graphics/powerup_laser_1.png",
    Type.C: "res://assets/graphics/powerup_catch_1.png",
    Type.E: "res://assets/graphics/powerup_expand_1.png",
    Type.D: "res://assets/graphics/powerup_duplicate_1.png",
    Type.B: "res://assets/graphics/powerup_warp_1.png",
    Type.P: "res://assets/graphics/powerup_life_1.png"
}

func _ready():
    # If type was set externally (by GameManager), override the texture
    # Else random (fallback)
    # Note: GameManager sets type BEFORE adding to tree, so _ready runs after.
    var tex = TEXTURES.get(type)
    if tex:
        sprite.texture = load(tex)

func _exit_tree():
    GameManager.powerup_gone()

func _process(delta):
    position.y += SPEEDS * delta
    if position.y > 600:
        queue_free()

func _on_body_entered(body):
    if body.name == "Vaus":
        AudioManager.play("powerup")
        apply_powerup(body)
        queue_free()

func apply_powerup(vaus):
    GameManager.apply_powerup(type, vaus)
