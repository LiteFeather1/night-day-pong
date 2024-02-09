class_name Block
extends StaticBody2D


signal hit(block: Block)


var id: int


func set_layer(layer_id: int) -> void:
	id = layer_id
	set_collision_layer_value(layer_id + 3, true)


func flip() -> void:
	set_collision_layer_value(id + 3, false)
	hit.emit(self)

