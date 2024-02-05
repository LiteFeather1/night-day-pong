class_name Trail
extends Line2D


@export var max_point_count = 50


func  _process(_delta: float) -> void:
	add_point(get_parent().global_position)
	
	while get_point_count() > max_point_count:
		remove_point(0)

