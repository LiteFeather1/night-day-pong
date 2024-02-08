class_name BallHitParticle
extends CPUParticles2D


signal finished_playing(instance: BallHitParticle)


func play(hit_point: Vector2, normal: Vector2, colour: Color) -> void:
	position = hit_point
	direction = normal
	color = colour
	emitting = true


func _on_finished() -> void:
	finished_playing.emit(self)

