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
    loader.load_level_from_image(current_level_node, level_num)

func _process(_delta):
    # Check if ball is lost
    # Better to have the ball emit a signal, but polling here is simple for now
    var balls = get_tree().get_nodes_in_group("Balls")
    # Actually, let's just use the children.
    # A cleaner way is to having the Ball emit 'tree_exiting' or handle it in Ball.gd
    pass
    
func _on_ball_lost():
    # Called when ball dies
    GameManager.lose_life()
    spawn_ball() # Or wait for input
