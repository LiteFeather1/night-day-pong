class_name Ball
extends CharacterBody2D


signal on_hit(hit_point: Vector2, normal: Vector2, colour: Color)

@export var sprite_2d: Sprite2D


func _process(delta: float) -> void:
	var collision_info = move_and_collide(velocity * delta)
	
	if collision_info:
		var normal = collision_info.get_normal()
		velocity = velocity.bounce(normal)
		
		on_hit.emit(collision_info.get_position(), normal, sprite_2d.modulate)
		
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

