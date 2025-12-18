extends CharacterBody2D

const SPEED = 350.0 # Base speed
const ACCEL = 20.0
const FRICTION = 15.0

var input_axis = 0.0
var width = 80.0 # Default width (sprite is 79)

enum State { NORMAL, LASER, CATCH, EXPAND }
var current_state = State.NORMAL

@onready var sprite = $Sprite2D
@onready var collision = $CollisionShape2D
@onready var laser_marker_l = $LaserLeft
@onready var laser_marker_r = $LaserRight
@export var laser_scene: PackedScene

func _physics_process(_delta):
    # Mouse movement
    var mouse_x = get_global_mouse_position().x
    # Simple deadzone check or just direct follow
    velocity.x = (mouse_x - global_position.x) * 10.0 # Proportional control
    
    # Keyboard override
    input_axis = Input.get_axis("move_left", "move_right")
    if input_axis:
        velocity.x = move_toward(velocity.x, input_axis * SPEED, ACCEL)
    
    move_and_slide()
    
    # Clamp position to screen bounds
    global_position.x = clamp(global_position.x, 24 + width/2, 424 - width/2)

    if Input.is_action_just_pressed("fire"):
        if current_state == State.LASER:
            fire_laser()
        elif current_state == State.CATCH:
            release_ball()

func fire_laser():
    # Logic to instance lasers
    if laser_scene:
        var l1 = laser_scene.instantiate()
        var l2 = laser_scene.instantiate()
        l1.global_position = laser_marker_l.global_position
        l2.global_position = laser_marker_r.global_position
        get_parent().add_child(l1)
        get_parent().add_child(l2)
        # Play sound
        AudioStreamPlayer.new().play() # Placeholder

func release_ball():
    # Signal to ball to detach
    pass

func transform_to(new_state):
    current_state = new_state
    # Update sprite and collision shape based on state
    match current_state:
        State.EXPAND:
            width = 48.0
            # Scale sprite/collision
        _:
            width = 32.0
