class_name Block
extends StaticBody2D

signal hit(block: Block)

@export var sprite: Sprite2D

var prev_layer: int

func set_layer(layer_id: int, colour: Color):
	prev_layer = layer_id + 3
	set_collision_layer_value(prev_layer, true)
	sprite.modulate = colour


func flip():
	set_collision_layer_value(prev_layer, false)
	hit.emit(self)
