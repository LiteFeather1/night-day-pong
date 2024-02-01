class_name Ball
extends CharacterBody2D

@export var sprite_2d: Sprite2D


func _process(delta: float) -> void:
	var collision_info = move_and_collide(velocity * delta)
	
	if collision_info:
		velocity = velocity.bounce(collision_info.get_normal())
		
		var block = collision_info.get_collider() as Block
		if block:
			block.flip()


func set_id(id: int, c: Color) -> void:
	set_collision_layer_value(id + 1, true)
	
	set_collision_mask_value(id + 1, true)
	set_collision_mask_value(4 - id, true)
	
	sprite_2d.modulate = c


func launch(force: Vector2) -> void:
	velocity = force 

