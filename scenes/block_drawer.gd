class_name BlockDrawer
extends Node2D


@export var main: Main


@export_range(0.0, 1.0) var stroke_width: float = .975


func _draw() -> void:
	var stroke_size := main.BLOCK_SIZE * main.block_scale
	var block_size := stroke_size * stroke_width
	var offset := block_size * .5
	
	if main.scale_position:
		draw_rect(Rect2(0.0, 0.0, 
				main.collums * stroke_size * 2.0, main.rows * stroke_size), main.line_colour)
		
		for i in main.all_blocks.size():
			var colour := main.colours[(i + 1) % 2]
			for j in get_range(i):
				var block: Block = main.all_blocks[i][j]
				draw_rect(Rect2(block.position.x - offset, block.position.y - offset, 
						block_size, block_size), colour)
	else:
		var stroke_offset := stroke_size * .5
		for i in main.all_blocks.size():
			var colour := main.colours[(i + 1) % 2]
			for j in get_range(i):
				var block: Block = main.all_blocks[i][j]
				draw_rect(Rect2(block.position.x - stroke_offset, block.position.y - stroke_offset,
						stroke_size, stroke_size), main.line_colour)
				
				draw_rect(Rect2(block.position.x - offset, block.position.y - offset, 
						block_size, block_size), colour)
	
	print(type_string(typeof(range(0))))


func get_range(index: int) -> Array:
	return range(main.all_blocks[index].size() - 1, -1 , -1)


func redraw() -> void:
	queue_redraw()
