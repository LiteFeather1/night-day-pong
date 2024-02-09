class_name Trail
extends Line2D


@export var max_point_count = 64


func  _process(_delta: float) -> void:
	add_point(get_parent().global_position)
	
	while get_point_count() > max_point_count:
		remove_point(0)


func set_state(state: bool) -> void:
	if state:
		process_mode = Node.PROCESS_MODE_INHERIT
	else:
		process_mode = Node.PROCESS_MODE_DISABLED
		clear_points()
