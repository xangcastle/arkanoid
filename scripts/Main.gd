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
	start_game()

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
	load_level(GameManager.level)
	spawn_ball()
	if vaus:
		vaus.position = Vector2(224, 450)

func _on_game_over():
	# Simple Game Over for now
	var label = Label.new()
	label.text = "GAME OVER"
	label.position = Vector2(180, 250)
	add_child(label)
	await get_tree().create_timer(3.0).timeout
	label.queue_free()
	start_game()

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
	# Check if ball is lost
	# Better to have the ball emit a signal, but polling here is simple for now
	var balls = get_tree().get_nodes_in_group("Balls")
	# Actually, let's just use the children.
	# A cleaner way is to having the Ball emit 'tree_exiting' or handle it in Ball.gd
	
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
	
	# The ball calling this is likely still in the group but queued for freeing or about to be?
	# Actually, queue_free happens after this frame usually, but let's assume the signal caller is dying.
	# If explicit count is 0 (excluding the one calling if we could filter it), then lose life.
	
	# A safer way: Wait a frame or just check count <= 1 (the one dying)
	if active_count <= 1:
		GameManager.lose_life()
		spawn_ball()
		# Just one ball died, others remain
		AudioManager.play("powerup")

func _unhandled_input(event):
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
				print("Debug Powerup: ", type)
				GameManager.apply_powerup(type, player)
				AudioManager.play("powerup")
		
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
