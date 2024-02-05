class_name BallHitParticle
extends CPUParticles2D


signal finished_playing(instance: BallHitParticle)


func _on_finished() -> void:
	finished_playing.emit(self)

