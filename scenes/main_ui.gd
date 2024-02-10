class_name MainUI
extends CanvasLayer


@export_category("Time")
@export var l_time: Label

@export_category("Scores")
# TODO consider colouring the label with the same colour of the balls
@export var l_scores: Array[Label]


func set_time(time: float) -> void:
	l_time.set_text("%02d : %02d" % [time / 60.0, fmod(time, 60.0)])


func set_score(index: int, score: int) -> void:
	l_scores[index].set_text("%d" % score)

