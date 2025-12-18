extends CharacterBody2D

const BASE_SPEED = 300.0
const MAX_SPEED = 800.0

var current_speed = BASE_SPEED
var direction = Vector2.UP
var active = false
var stuck_to_paddle = null
var stuck_offset = Vector2.ZERO

var active_lock = false

func start_on_paddle(paddle):
	active = false
	stuck_to_paddle = paddle
	stuck_offset = Vector2(0, -10)
	global_position = paddle.global_position + stuck_offset

func launch():
	if not active:
		active = true
		active_lock = true
		stuck_to_paddle = null
		direction = Vector2(0.5, -1).normalized()
		velocity = direction * current_speed
		# Unlock capture after a moment
		get_tree().create_timer(0.5).timeout.connect(func(): active_lock = false)

func slow_down():
	current_speed = BASE_SPEED

func duplicate_ball():
	var new_ball = duplicate()
	new_ball.position = position
	new_ball.direction = direction.rotated(randf_range(-0.5, 0.5))
	new_ball.active = true
	get_parent().call_deferred("add_child", new_ball)

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
			
			# Increase speed slightly on paddle hit
			current_speed = min(current_speed + 10.0, MAX_SPEED)
			
			# Catch logic if enabled (call release_ball on paddle input)
			# Only catch if ball is moving down (avoids re-catch on launch)
			# Actually, we just set velocity UP above, so we can't check current velocity.y (it's neg).
			# We should check the collision normal or old velocity if possible.
			# But simpler: If we are in CATCH state, we stick.
			# To avoid insta-catch: The ball MUST be coming from above.
			# Since we handle bounce first, we are moving up now.
			# Let's rely on a timer or 'active' flag grace period?
			# No, simpler: check if collision normal is generally down?
			# Actually, if we just launched, stuck_to_paddle is null.
			# Collisions happen -> bounce -> catch.
			# We need to distinguish "Landing on paddle" vs "Just launched".
			# When launched, we start slightly above stuck pos?
			if paddle.current_state == paddle.State.CATCH and not active_lock:
				start_on_paddle(paddle)

	# Brick interaction
	if collision and collision.get_collider().has_method("hit"):
		collision.get_collider().hit()
		current_speed = min(current_speed + 2.0, MAX_SPEED)
			 
	if global_position.y > 550:
		 # Ball died
		var main = get_parent()
		if main.has_method("_on_ball_lost"):
			main._on_ball_lost()
		queue_free()
