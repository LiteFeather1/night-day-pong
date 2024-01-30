class_name Block
extends StaticBody2D

signal hit(block: Block)

@export var sprite_line: Sprite2D
@export var sprite_block: Sprite2D

var prev_layer: int

func set_line(colour: Color) -> void:
	sprite_line.modulate = colour


func set_layer(layer_id: int, colour: Color) -> void:
	prev_layer = layer_id + 3
	set_collision_layer_value(prev_layer, true)
	sprite_block.modulate = colour


func flip() -> void:
	set_collision_layer_value(prev_layer, false)
	hit.emit(self)
