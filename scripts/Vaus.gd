extends CharacterBody2D

const SPEED = 350.0 # Base speed
const ACCEL = 20.0
const FRICTION = 15.0

var input_axis = 0.0
var width = 80.0 # Default width (sprite is 79)
var is_controlling = false # Disable control during spawn/death

enum State { NORMAL, LASER, CATCH, EXPAND }
var current_state = State.NORMAL

@onready var sprite = $AnimatedSprite2D
@onready var collision = $CollisionShape2D
@onready var laser_marker_l = $LaserLeft
@onready var laser_marker_r = $LaserRight
@export var laser_scene: PackedScene

# --- Animation Setup ---
static var frames_cache: SpriteFrames = null

func _ready():
	_setup_animations()
	appear()

func _setup_animations():
	if frames_cache:
		sprite.sprite_frames = frames_cache
		return
		
	var frames = SpriteFrames.new()
	frames_cache = frames
	
	# Helper to load sequence
	var load_seq = func(anim_name, prefix, count, loop=false, fps=24.0):
		frames.add_animation(anim_name)
		frames.set_animation_loop(anim_name, loop)
		frames.set_animation_speed(anim_name, fps)
		for i in range(1, count + 1):
			var path = "res://assets/graphics/paddle_%s_%d.png" % [prefix, i]
			if ResourceLoader.exists(path):
				frames.add_frame(anim_name, load(path))
			else:
				# Fallback for single frame or broken seq
				pass
	
	# IDLE / PULSATE
	load_seq.call("normal", "pulsate", 4, true, 8.0)
	load_seq.call("laser", "laser_pulsate", 4, true, 8.0)
	load_seq.call("expand", "wide_pulsate", 4, true, 8.0)
	
	# TRANSITIONS (Morphs)
	load_seq.call("morph_laser", "laser", 16, false, 24.0)
	load_seq.call("morph_expand", "wide", 9, false, 24.0)
	
	# EVENTS
	load_seq.call("materialize", "materialize", 15, false, 20.0)
	load_seq.call("explode", "explode", 8, false, 15.0)

	sprite.sprite_frames = frames_cache

func appear():
	is_controlling = false
	sprite.play("materialize")
	await sprite.animation_finished
	sprite.play("normal")
	is_controlling = true

func die():
	is_controlling = false
	sprite.play("explode")
	AudioManager.play("explosion")
	await sprite.animation_finished
	hide()
	# GameManager will handle respawn/game over via signal or direct call? 
	# Usually Main.gd connects to "tree_exited" or "child_exiting_tree" or we emit signal.
	# For now, let's just queue_free which triggers Main's detection (if any)
	# But checking Main.gd, it uses `_on_player_died`. We should look at how it detects death.
	# Main.gd checks `if not has_node("Vaus")`. So queue_free is correct.
	queue_free()

func _physics_process(_delta):
	if not is_controlling: return

	# Mouse movement
	var mouse_x = get_global_mouse_position().x
	velocity.x = (mouse_x - global_position.x) * 10.0
	
	# Keyboard override
	input_axis = Input.get_axis("move_left", "move_right")
	if input_axis:
		velocity.x = move_toward(velocity.x, input_axis * SPEED, ACCEL)
	
	move_and_slide()
	
	# Clamp position to screen bounds
	global_position.x = clamp(global_position.x, width/2, 448 - width/2)

	if Input.is_action_just_pressed("fire"):
		if current_state == State.LASER:
			fire_laser()
		elif current_state == State.CATCH:
			release_ball()
		else:
			var balls = get_tree().get_nodes_in_group("Balls")
			for b in balls:
				if not b.active:
					b.launch()

func fire_laser():
	if laser_scene:
		var l1 = laser_scene.instantiate()
		var l2 = laser_scene.instantiate()
		l1.global_position = laser_marker_l.global_position
		l2.global_position = laser_marker_r.global_position
		get_parent().add_child(l1)
		get_parent().add_child(l2)
		AudioManager.play("laser")

func release_ball():
	var balls = get_tree().get_nodes_in_group("Balls")
	for b in balls:
		if b.stuck_to_paddle:
			b.launch()

func transform_to(new_state):
	# If already same state, ignore or just re-apply stats
	if current_state == new_state: return

	current_state = new_state
	
	# Reset baseline stats
	width = 80.0
	collision.shape.size.x = 78.0
	# Remove any scaling hacks from previous sprite impl
	sprite.scale = Vector2(1, 1)

	match current_state:
		State.NORMAL:
			sprite.play("normal")
			
		State.LASER:
			# Play morph then loop
			sprite.play("morph_laser")
			await sprite.animation_finished
			# Check if state changed during anim?
			if current_state == State.LASER:
				sprite.play("laser")
			
		State.EXPAND:
			width = 112.0
			collision.shape.size.x = 110.0 # Update collider for wide
			
			sprite.play("morph_expand")
			await sprite.animation_finished
			if current_state == State.EXPAND:
				sprite.play("expand")
				
		State.CATCH:
			# No specific anim for catch, reuse normal? Or maybe overlay?
			# Using "normal" (pulsate) for now as there is no catch anim asset
			sprite.play("normal")
			
	# Others...
	
func reset_state():
	transform_to(State.NORMAL)
