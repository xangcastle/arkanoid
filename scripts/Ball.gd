extends CharacterBody2D

const BASE_SPEED = 300.0
const MAX_SPEED = 800.0

var current_speed = BASE_SPEED
var direction = Vector2.UP
var active = false
var stuck_to_paddle = null
var stuck_offset = Vector2.ZERO

func start_on_paddle(paddle):
	active = false
	stuck_to_paddle = paddle
	stuck_offset = Vector2(0, -10)
	global_position = paddle.global_position + stuck_offset

func launch():
	if not active:
		active = true
		stuck_to_paddle = null
		direction = Vector2(0.5, -1).normalized()
		velocity = direction * current_speed

func _physics_process(delta):
	if not active:
		if stuck_to_paddle:
			global_position = stuck_to_paddle.global_position + stuck_offset
		
		if Input.is_action_just_pressed("fire") or Input.is_action_just_pressed("start"):
			launch()
		return

	# Tunneling prevention
	var motion = velocity * delta
	var collision = move_and_collide(motion)
	
	if collision:
		velocity = velocity.bounce(collision.get_normal())
		
		# Audio
		if collision.get_collider().name == "Vaus":
			AudioManager.play("paddle_hit")
		else:
			 # Basic bounce sound if wall?
			pass
		
		# Special interaction with Paddle
		if collision.get_collider().name == "Vaus":
			var paddle = collision.get_collider()
			var diff_x = global_position.x - paddle.global_position.x
			var width = 32.0 # Get from paddle
			var ratio = diff_x / (width / 2.0)
			ratio = clamp(ratio, -1.0, 1.0)
			
			# Change angle
			var new_angle = ratio * 60.0 # deg
			velocity = Vector2.UP.rotated(deg_to_rad(new_angle)) * current_speed
			
			# Catch logic if enabled (call release_ball on paddle input)
			if paddle.current_state == paddle.State.CATCH:
				start_on_paddle(paddle)

		# Brick interaction
		if collision.get_collider().has_method("hit"):
			collision.get_collider().hit()
			 
	if global_position.y > 550:
		 # Ball died
		var main = get_parent()
		if main.has_method("_on_ball_lost"):
			main._on_ball_lost()
		queue_free()
