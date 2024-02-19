class_name MainUI
extends CanvasLayer


signal start_game()


@export var hud: Control

@export_category("Time")
@export var l_time: Label

@export_category("Scores")
# TODO consider colouring the label with the same colour of the balls
@export var l_scores: Array[Label]

@export_category("")
@export var b_start: Button


func _ready() -> void:
	hud.visible = false
	hud.modulate = Color(1.0, 1.0, 1.0, 0.0)


func set_time(time: float) -> void:
	l_time.set_text("%02d : %02d" % [time / 60.0, fmod(time, 60.0)])


func set_score(index: int, score: int) -> void:
	l_scores[index].set_text("%d" % score)


func set_score_colour(index: int, colour: Color) -> void:
	l_scores[index].modulate = colour


func _on_b_start_pressed() -> void:
	b_start.disabled = true
	var tween: Tween = create_tween()
	tween.tween_property(b_start, "modulate", Color(1.0, 1.0, 1.0, 0.0), 0.2).set_ease(Tween.EASE_IN_OUT)
	const delay := .05
	tween.tween_callback(func(): 
		b_start.visible = false
		hud.visible = true).set_delay(delay)
	tween.tween_property(hud, "modulate", Color.WHITE, .33).set_delay(delay)
	
	start_game.emit()
