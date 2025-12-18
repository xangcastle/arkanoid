extends Area2D

enum Type { S, L, C, E, D, B, P }
var type = Type.S

const SPEEDS = 100.0

@onready var sprite = $AnimatedSprite2D

# Cache for SpriteFrames
static var frames_cache = {}

const TYPE_NAMES = {
	Type.S: "slow",
	Type.L: "laser",
	Type.C: "catch",
	Type.E: "expand",
	Type.D: "duplicate",
	Type.B: "warp",
	Type.P: "life"
}

func _ready():
	_setup_animation()

func _setup_animation():
	if type in frames_cache:
		sprite.sprite_frames = frames_cache[type]
		sprite.play("default")
		return

	var frames = SpriteFrames.new()
	var anim_name = "default"
	frames.add_animation(anim_name)
	frames.set_animation_loop(anim_name, true)
	frames.set_animation_speed(anim_name, 12.0) # 12 FPS for powerups (slower rotation)
	
	var base_name = TYPE_NAMES.get(type, "laser")
	
	# Load frames (Try up to 16, break if missing)
	for i in range(1, 17):
		var path = "res://assets/graphics/powerup_%s_%d.png" % [base_name, i]
		if ResourceLoader.exists(path):
			var tex = load(path)
			frames.add_frame(anim_name, tex)
		else:
			break # Stop on first missing frame
			
	frames_cache[type] = frames
	sprite.sprite_frames = frames
	sprite.play(anim_name)

func _exit_tree():
	GameManager.powerup_gone()

func _process(delta):
	position.y += SPEEDS * delta
	if position.y > 600:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("Player"):
		GameManager.apply_powerup(type, body)
		AudioManager.play("powerup")
		queue_free()
		apply_powerup(body)
		queue_free()

func apply_powerup(vaus):
	GameManager.apply_powerup(type, vaus)
