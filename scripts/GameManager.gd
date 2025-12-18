extends Node

signal score_changed(new_score)
signal lives_changed(new_lives)
signal level_completed
signal game_over
signal player_died

var score = 0
var high_score = 50000
var lives = 3
var level = 1
var max_levels = 36 # approx

# Powerup System
var active_powerups_count = 0 
var bricks_destroyed_since_last = 0
var drop_threshold = 0
var powerup_bag = []

func _ready():
    process_mode = Node.PROCESS_MODE_ALWAYS
    reset_powerup_logic()

func on_player_hit():
    player_died.emit()
    lose_life()

func reset_powerup_logic():
    active_powerups_count = 0
    bricks_destroyed_since_last = 0
    drop_threshold = randi_range(5, 10) 
    refill_bag()

func refill_bag():
    # Weigh generic types higher
    # S=0, L=1, C=2, E=3, D=4, B=5, P=6
    var types = [0,0,0, 1,1,1, 2,2,2, 3,3,3, 4,4,4, 5, 6] 
    types.shuffle()
    powerup_bag = types

func attempt_drop_powerup(pos):
    if active_powerups_count > 0:
        return
        
    bricks_destroyed_since_last += 1
    
    if bricks_destroyed_since_last >= drop_threshold:
        spawn_powerup(pos)
        bricks_destroyed_since_last = 0
        drop_threshold = randi_range(10, 15)

func spawn_powerup(pos):
    if powerup_bag.is_empty():
        refill_bag()
    
    var type_int = powerup_bag.pop_back()
    
    var main = get_tree().current_scene
    if not main: return

    var pu_scene = load("res://scenes/entities/PowerUp.tscn")
    var pu = pu_scene.instantiate()
    pu.type = type_int
    pu.position = pos
    main.call_deferred("add_child", pu)
    
    active_powerups_count += 1

func spawn_specific_powerup(pos, type_int):
    var main = get_tree().current_scene
    if not main: return

    var pu_scene = load("res://scenes/entities/PowerUp.tscn")
    var pu = pu_scene.instantiate()
    pu.type = type_int
    pu.position = pos
    main.call_deferred("add_child", pu)
    
    active_powerups_count += 1

func powerup_gone():
    active_powerups_count = max(0, active_powerups_count - 1)

func add_score(points):
    score += points
    if score > high_score:
        high_score = score
    score_changed.emit(score)

func lose_life():
    reset_powerup_effects()
    lives -= 1
    lives_changed.emit(lives)
    if lives < 0:
        game_over.emit()
    else:
        pass

func add_life():
    lives += 1
    lives_changed.emit(lives)

func reset_game():
    score = 0
    lives = 3
    level = 1
    score_changed.emit(score)
    lives_changed.emit(lives)
    reset_powerup_logic()

func next_level():
    reset_powerup_effects()
    level += 1
    level_completed.emit()

func reset_powerup_effects():
    var vaus = get_tree().get_first_node_in_group("Player")
    if vaus and vaus.has_method("reset_state"):
        vaus.reset_state()
    
    # Also reset slow ball speed? Usually speed persists, but sticking resets.
    var balls = get_tree().get_nodes_in_group("Balls")
    for b in balls:
        if b.has_method("slow_down"):
            b.slow_down()
        if "stuck_to_paddle" in b:
            b.stuck_to_paddle = null
            b.active_lock = false


func check_level_completion():
    var bricks = get_tree().get_nodes_in_group("Bricks")
    var breakable_count = 0
    for b in bricks:
        if is_instance_valid(b) and not b.is_queued_for_deletion():
            # Assuming 'type' property access or method to check if breakable
            # Gold bricks are type 9 (from Brick.gd logic inferred, let's Verify)
            if b.get("type") != 9: # Type.GOLD
                breakable_count += 1
    
    print("Level Completion Check: ", breakable_count, " breakable bricks remaining.")
    
    if breakable_count == 0:
        print("Level Complete! Moving to next...")
        call_deferred("next_level")

func apply_powerup(type, vaus):
    # S=0, L=1, C=2, E=3, D=4, B=5, P=6
    match type:
        0: # S
            get_tree().call_group("Balls", "slow_down")
        1: # L
            if vaus.has_method("transform_to"):
                vaus.transform_to(1) # State.LASER = 1
        2: # C
            if vaus.has_method("transform_to"):
                vaus.transform_to(2) # State.CATCH = 2
        3: # E
            if vaus.has_method("transform_to"):
                vaus.transform_to(3) # State.EXPAND = 3
        4: # D
            var balls = get_tree().get_nodes_in_group("Balls")
            if balls.size() > 0:
                balls[0].duplicate_ball()
                balls[0].duplicate_ball()
        5: # B
            next_level()
        6: # P
            add_life()
            AudioManager.play("life")
