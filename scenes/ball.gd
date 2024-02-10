class_name Ball
extends CharacterBody2D


signal on_hit(hit_point: Vector2, normal: Vector2, id: int)


@export var trail: Trail

var id: int = -1 

func _process(delta: float) -> void:
	var collision_info := move_and_collide(velocity * delta)
	
	if collision_info == null:
		return
	
	var normal := collision_info.get_normal()
	velocity = velocity.bounce(normal)
	
	on_hit.emit(collision_info.get_position(), normal, id)
	
	var block := collision_info.get_collider() as Block
	if block:
		block.flip()


func set_pos_scale(pos: Vector2, scal: float) -> void:
	position = pos
	scale = Vector2(scal, scal)
	trail.width *= scal


func set_id(i: int) -> void:
	id = i
	var layer := i + 1
	set_collision_layer_value(layer, true)
	
	set_collision_mask_value(layer, true)
	set_collision_mask_value(4 - i, true)


func launch(force: Vector2) -> void:
	velocity = force 

