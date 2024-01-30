class_name Ball
extends CharacterBody2D

@export var sprite_2d: Sprite2D

var force: float = 0.0
var id: int

func _process(delta: float) -> void:
	var collision_info = move_and_collide(velocity * delta)
	
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
		
		var block = collision_info.get_collider() as Block
		if block:
			block.flip()


func set_id(_id: int, c: Color) -> void:
	id = id + 1
	set_collision_layer_value(id, true)
	set_collision_mask_value(4 - _id, true)
	sprite_2d.modulate = c


func launch(_force: float) -> void:
	force = _force
	velocity = Vector2(1, randf_range(-1.0, 1.0)).normalized() * force
