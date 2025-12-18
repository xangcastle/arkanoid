extends Node

const BRICK_SCENE = preload("res://scenes/entities/Brick.tscn")
const BRICK_W = 32
const BRICK_H = 16
const OFFSET_X = 0 # Files seem to be 14 cols * 32 = 448 full width
const OFFSET_Y = 24 # Start a bit down, though files have empty dots

const CHAR_MAP = {
    'w': 0, # White
    'o': 1, # Orange
    'c': 2, # Cyan
    'g': 3, # Green
    'r': 4, # Red
    'b': 5, # Blue
    'p': 6, # Pink
    'y': 7, # Yellow
    's': 8, # Silver
    'd': 9  # Gold
}

static func load_level(parent: Node, level_num: int):
    var path = "res://assets/levels/level" + str(level_num) + ".txt"
    if not FileAccess.file_exists(path):
        print("Level file not found: ", path)
        return

    var file = FileAccess.open(path, FileAccess.READ)
    var content = file.get_as_text()
    var lines = content.split("\n")
    
    var y = OFFSET_Y
    for line in lines:
        var x = OFFSET_X
        # 14 chars max usually
        for i in range(min(line.length(), 14)):
            var char = line[i]
            if CHAR_MAP.has(char):
                var type = CHAR_MAP[char]
                spawn_brick(parent, x, y, type)
            x += BRICK_W
        y += BRICK_H

static func spawn_brick(parent, x, y, type):
    var brick = BRICK_SCENE.instantiate()
    brick.type = type
    brick.position = Vector2(x + BRICK_W/2, y + BRICK_H/2) # Center position
    parent.add_child(brick)
