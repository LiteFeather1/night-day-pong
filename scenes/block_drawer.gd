class_name BlockDrawer
extends Node2D

@export var main: Main

@export_range(0.0, 1.0) var stroke: float = .95

func _draw() -> void:
	var length = main.all_blocks.size()
	var size = main.BLOCK_SIZE * main.block_scale
	var block_scale = size * stroke
	var offset = block_scale * .5
	var block_size = Vector2(block_scale, block_scale)
	if main.scale_position:
		var s = Vector2(main.collums * size * 2, main.rows * size)
		draw_rect(Rect2(Vector2.ZERO, s), main.line_colour)
		
		for i in length:
			for block in main.all_blocks[i]:
				var p = Vector2(block.position.x - offset, block.position.y - offset)
				draw_rect(Rect2(p, block_size), main.colours[length - i -1])
	else:
		var stroke_size = Vector2(size, size)
		var stroke_offset = size * .5
		for i in length:
			for block in main.all_blocks[i]:
				var stroke_p = Vector2(block.position.x - stroke_offset, block.position.y - stroke_offset)
				draw_rect(Rect2(stroke_p, stroke_size), main.line_colour)
				
				var p = Vector2(block.position.x - offset, block.position.y - offset)
				draw_rect(Rect2(p, block_size), main.colours[length - i -1])

