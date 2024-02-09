class_name Block
extends StaticBody2D


signal hit(block: Block)

@export var sprite_line: Sprite2D
@export var sprite_block: Sprite2D

var id: int


func set_line(colour: Color) -> void:
	sprite_line.modulate = colour


func set_layer(layer_id: int, colour: Color) -> void:
	id = layer_id
	set_collision_layer_value(layer_id + 3, true)
	sprite_block.modulate = colour


func flip() -> void:
	set_collision_layer_value(id + 3, false)
	hit.emit(self)

