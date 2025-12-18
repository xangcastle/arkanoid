extends Node2D

@export var vaus_scene: PackedScene
@export var ball_scene: PackedScene

var current_level_node: Node2D
var vaus: Node2D

@onready var score_label = $CanvasLayer/ScoreLabel
@onready var high_score_label = $CanvasLayer/HighScoreLabel
@onready var lives_label = $CanvasLayer/LivesLabel

func _ready():
	GameManager.score_changed.connect(_on_score_changed)
	GameManager.lives_changed.connect(_on_lives_changed)
	GameManager.level_completed.connect(_on_level_completed)
	GameManager.game_over.connect(_on_game_over)
	GameManager.player_died.connect(_on_player_died)
	
	# Capture mouse to keep it in window and hide it (User request)
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN
	
	# Main must run while paused to handle input
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	create_pause_label()
	start_game()

func create_pause_label():
	var label = Label.new()
	label.text = "PAUSED\nCLICK TO RESUME"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.name = "PauseLabel"
	label.visible = false
	# Center it
	label.anchors_preset = Control.PRESET_CENTER
	label.position = Vector2(224 - 50, 256 - 20) # Approx center
	
	# Add to CanvasLayer
	$CanvasLayer.add_child(label)

func pause_game():
	get_tree().paused = true
	var label = $CanvasLayer/PauseLabel
	if label: label.show()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE

func resume_game():
	get_tree().paused = false
	var label = $CanvasLayer/PauseLabel
	if label: label.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CONFINED_HIDDEN

func _on_player_died():
	call_deferred("_deferred_player_died")

func _deferred_player_died():
	if vaus and is_instance_valid(vaus):
		vaus.queue_free()
	get_tree().call_group("Balls", "queue_free")
	
	if GameManager.lives >= 0:
		spawn_player()

func _on_level_completed():
	call_deferred("_deferred_level_load")

func _deferred_level_load():
	get_tree().call_group("Balls", "queue_free")
	
	# Overlay warp transition
	var warp_scene = load("res://scenes/core/Warp.tscn")
	var warp = warp_scene.instantiate()
	# Add to a CanvasLayer for top-level rendering if possible, but Main is a Node2D.
	# The Warp scene itself should ideally be on a CanvasLayer or high z-index.
	# Assuming Warp.tscn is just Control/Node2D.
	# In previous edits I added it to a specific layer but here I'll just add as child
	# since user checked it before.
	# Wait, previous edit added it to a CanvasLayer constructed on the fly?
	# "Updated _deferred_level_load to add the Warp scene to a CanvasLayer"
	# Let's check if I should do that.
	var layer = CanvasLayer.new()
	layer.layer = 100
	add_child(layer)
	layer.add_child(warp)
	
	# Wait for warp to finish
	await warp.warp_finished
	
	load_level(GameManager.level)
	spawn_ball()
	if vaus and is_instance_valid(vaus):
		vaus.position = Vector2(224, 450)
	
	# Cleanup layer
	layer.queue_free()

func _on_game_over():
	get_tree().change_scene_to_file("res://scenes/core/GameOver.tscn")

func start_game():
	GameManager.reset_game()
	load_level(1)
	spawn_player()
	update_hud()

func update_hud():
	score_label.text = "SCORE: " + str(GameManager.score)
	high_score_label.text = "HIGH: " + str(GameManager.high_score)
	lives_label.text = "LIVES: " + str(GameManager.lives)

func _on_score_changed(new_score):
	score_label.text = "SCORE: " + str(new_score)
	high_score_label.text = "HIGH: " + str(GameManager.high_score)

func _on_lives_changed(new_lives):
	lives_label.text = "LIVES: " + str(new_lives)

func spawn_player():
	if vaus and is_instance_valid(vaus):
		vaus.queue_free()
	
	if not vaus_scene:
		print("Vaus scene not assigned!")
		return

	vaus = vaus_scene.instantiate()
	vaus.position = Vector2(224, 450)
	add_child(vaus)
	
	spawn_ball()

func spawn_ball():
	if not ball_scene:
		return
		
	# Safety check: if Vaus is dead/missing, don't spawn ball yet
	if not vaus or not is_instance_valid(vaus):
		return

	var ball = ball_scene.instantiate()
	ball.start_on_paddle(vaus)
	add_child(ball)

func load_level(level_num):
	if current_level_node:
		current_level_node.queue_free()
	
	current_level_node = Node2D.new()
	current_level_node.name = "LevelContainer"
	add_child(current_level_node)
	
	# Use LevelLoader class
	var loader = load("res://scripts/LevelLoader.gd")
	loader.load_level(current_level_node, level_num)
	print("Level ", level_num, " Loaded")

func _process(_delta):
	if get_tree().paused:
		return

	# Check if ball is lost
	var balls = get_tree().get_nodes_in_group("Balls")
	
	if randf() < 0.001: # Low chance per frame (~once per 16s at 60fps)
		spawn_enemy()
	
func _on_ball_lost():
	# Only lose life if no balls left
	var balls = get_tree().get_nodes_in_group("Balls")
	var active_count = 0
	for b in balls:
		# Check if b is valid and not queued for deletion
		if is_instance_valid(b) and not b.is_queued_for_deletion():
			active_count += 1
	
	if active_count <= 1:
		GameManager.lose_life()
		spawn_ball()
		AudioManager.play("powerup")

func _unhandled_input(event):
	# Handle Pause Input (Always check)
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_ESCAPE:
			if not get_tree().paused:
				pause_game()
			else:
				# Strict Click-to-Resume as requested
				pass
	
	if event is InputEventMouseButton and event.pressed:
		if get_tree().paused:
			resume_game()
			get_viewport().set_input_as_handled() # Consume input so it doesn't fire ball
			return

	# Debug Mode: Activate with ARK_DEBUG=1
	if OS.get_environment("ARK_DEBUG") != "1":
		return

	if event is InputEventKey and event.pressed:
		var type = -1
		match event.keycode:
			KEY_S: type = 0
			KEY_L: type = 1
			KEY_C: type = 2
			KEY_E: type = 3
			KEY_D: type = 4
			KEY_B: type = 5
			KEY_P: type = 6
		
		if type != -1:
			var player = get_tree().get_first_node_in_group("Player")
			if player:
				print("Debug Powerup Spawn: ", type)
				# Spawn at top of screen to test falling/collection
				GameManager.spawn_specific_powerup(Vector2(224, 60), type)
		
		# Debug Enemies
		if event.keycode >= KEY_1 and event.keycode <= KEY_4:
			var enemy_type = event.keycode - KEY_1
			spawn_enemy_debug(enemy_type)

func spawn_enemy_debug(type):
	var enemy_scene = load("res://scenes/entities/Enemy.tscn")
	var enemy = enemy_scene.instantiate()
	enemy.type = type
	enemy.position = Vector2(224, 100)
	add_child(enemy)


func spawn_enemy():
	var enemy_scene = load("res://scenes/entities/Enemy.tscn")
	var enemy = enemy_scene.instantiate()
	
	# Random type
	enemy.type = randi() % 4
	
	# Spawn at top left or right
	var spawn_x = 64 if randf() < 0.5 else 384
	enemy.position = Vector2(spawn_x, 40)
	add_child(enemy)
