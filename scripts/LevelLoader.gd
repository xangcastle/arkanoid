extends Node

const BRICK_SCENE = preload("res://scenes/entities/Brick.tscn")
const BRICK_W = 32
const BRICK_H = 16
const OFFSET_X = 32
const OFFSET_Y = 64

const COLOR_MAP = {
    Color(1, 1, 1): 0, # White
    Color(1, 0.5, 0): 1, # Orange
    Color(0, 1, 1): 2, # Cyan
    Color(0, 1, 0): 3, # Green
    Color(1, 0, 0): 4, # Red
    Color(0, 0, 1): 5, # Blue
    Color(1, 0, 1): 6, # Pink
    Color(1, 1, 0): 7, # Yellow
    Color(0.75, 0.75, 0.75): 8, # Silver
    Color(1, 0.84, 0): 9 # Gold
}

static func load_level_from_image(parent: Node, level_num: int):
    # Procedural generation for now
    var rows = 18
    var cols = 13 # 13 * 32 = 416. Screen width 448. (448-416)/2 = 16px margin.
    
    for r in range(rows):
        for c in range(cols):
            # Simple pattern: Skip some to make it interesting
            if r > 2 and r < 5 and c > 4 and c < 8:
                continue
            
            var brick = BRICK_SCENE.instantiate()
            # Cycle through colors based on element row
            brick.type = (r % 8) as int
            if r == 0: brick.type = 8 # Silver top
            
            # Position: Margin + column * width + half_width (center)
            brick.position = Vector2(16 + c * 32 + 16, OFFSET_Y + r * 16 + 8)
            parent.add_child(brick)
