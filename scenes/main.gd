extends Node2D

@onready var root: Window = get_tree().get_root()

@export_group("Nodes")
@export var camera_2d: Camera2D
@export var edge_colliders: Array[CollisionShape2D]

@export_group("Game Settings")
@export var collums: int = 4
@export var rows: int = 4

@export_group("Colours")
@export var colours: Array[Color]
@export var line_colour: Color = Color("ffffff7f")
@export var background_colour: Color = Color("1e1e1e")

@export_group("Ball Settings")
const ball_scene: PackedScene = preload("res://scenes/ball.tscn")
@export var ball_start_force: float = 1024
@export var ball_scale: float = 1.0

@export_group("Block Settings")
const block_scene: PackedScene = preload("res://scenes/block.tscn")
@export var block_scale: float = 1.0
@export var scale_position: bool = false
const BLOCK_SIZE: int = 128
const HALF_BLOCK_SIZE: int = 64


func _ready() -> void:
	# set clear colour
	RenderingServer.set_default_clear_color(background_colour)
	
	# set camera pos
	var scale_pos = 1.0 if !scale_position else block_scale
	var center_x = collums * BLOCK_SIZE * scale_pos
	var center_y = rows * BLOCK_SIZE * 0.5 * scale_pos
	camera_2d.position = Vector2(center_x, center_y)
	
	# init block positions
	var block_parents: Array[Node] = [Node.new(), Node.new()]
	for b in block_parents:
		root.add_child.call_deferred(b)
	
	for x in collums:
		for y in rows:
			for player in 2:
				var block: Block = block_scene.instantiate()
				var player_offset = player * center_x + HALF_BLOCK_SIZE * scale_pos
				var x_pos = x * BLOCK_SIZE * scale_pos + player_offset
				block.position = Vector2(x_pos, y * BLOCK_SIZE * scale_pos + HALF_BLOCK_SIZE * scale_pos)
				block.scale = Vector2(block_scale, block_scale)
				block.set_line(line_colour)
				block.set_layer(player, colours[colours.size() - player - 1])
				block.name = str(player)
				block.hit.connect(flip_block)
				block_parents[player].add_child.call_deferred(block)
	
	# set players
	const x_padding = 128.0
	spawn_ball(0, Vector2(x_padding, center_y))
	spawn_ball(1, Vector2(center_x * 2.0 - x_padding, center_y))
	
	# set edge colliders
	var top_right = Vector2(center_x * 2.0, 0.0)
	var s_top = edge_colliders[0].shape as SegmentShape2D
	s_top.a = Vector2.ZERO
	s_top.b = top_right
	
	var bot_right = Vector2(center_x * 2.0, center_y * 2.0)
	var s_right = edge_colliders[1].shape as SegmentShape2D
	s_right.a = top_right
	s_right.b = bot_right
	
	var bot_left = Vector2(0, center_y * 2.0)
	var s_bot = edge_colliders[2].shape as SegmentShape2D
	s_bot.a = bot_right
	s_bot.b = bot_left
	
	var s_left = edge_colliders[3].shape as SegmentShape2D
	s_left.a = bot_left
	s_left.b = Vector2.ZERO


func spawn_ball(index: int,pos: Vector2) -> void:
	var ball: Ball = ball_scene.instantiate()
	ball.set_id(index, colours[index])
	ball.position = pos
	ball.scale = Vector2(ball_scale, ball_scale)
	root.add_child.call_deferred(ball)
	ball.launch(random_inside_unit_circle() * ball_start_force)


func random_inside_unit_circle() -> Vector2:
	var theta = randf() * 2.0 * PI
	return Vector2(cos(theta), sin(theta)) * sqrt(randf())


func flip_block(block: Block) -> void:
	if block.prev_layer == 3:
		block.set_layer(1, colours[0])
	elif block.prev_layer == 4:
		block.set_layer(0, colours[1])

