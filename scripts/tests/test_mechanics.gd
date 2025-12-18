extends Node

func _ready():
    print("Starting mechanics verification...")
    
    # Wait one frame for autoloads? Usually ready is fine.
    await get_tree().process_frame
    
    verify_mechanics()
    
    print("Verification Complete.")
    get_tree().quit()

func verify_mechanics():
    var vaus_script = load("res://scripts/Vaus.gd")
    var vaus = vaus_script.new()
    if vaus.SPEED == 350.0:
        print("PASS: Vaus speed correct")
    else:
        print("FAIL: Vaus speed incorrect")

    var ball_script = load("res://scripts/Ball.gd")
    var ball = ball_script.new()
    if ball.BASE_SPEED == 300.0:
        print("PASS: Ball base speed correct")
    else:
        print("FAIL: Ball base speed incorrect")
        
    var brick_scene = load("res://scenes/entities/Brick.tscn")
    var brick = brick_scene.instantiate()
    brick.type = 4 # Red
    add_child(brick) # This triggers _ready() which calls setup_brick()
    
    if brick.value == 90:
        print("PASS: Red brick value correct")
    else:
        print("FAIL: Red brick value incorrect")
    
    brick.queue_free()
        
    # Test level loader?
    var level_loader = load("res://scripts/LevelLoader.gd")
    if level_loader:
        print("PASS: LevelLoader parsed")
