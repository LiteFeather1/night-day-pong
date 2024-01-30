extends Node2D

@onready var root: Window = get_tree().get_root()
@export var camera_2d: Camera2D

@export var colours: Array[Color]
@export var line_colour: Color
@export var background_colour: Color

@export var force: float = 10.0
@export var game_scale: Vector2 = Vector2(.5, .5)

@export var ball_scene: PackedScene = preload("res://scenes/ball.tscn")

const BLOCK_SIZE: int = 128
@export var block_scene: PackedScene = preload("res://scenes/block.tscn")
@export var collums: int = 1
@export var rows: int = 1

@export var edge_colliders: Array[CollisionShape2D]


func _ready() -> void:
	# set clear colour
	RenderingServer.set_default_clear_color(background_colour)
	
	# set camera pos
	var center_x = collums * BLOCK_SIZE * game_scale.x
	var center_y: float = rows * BLOCK_SIZE * game_scale.y  * .5
	camera_2d.position = Vector2(center_x, center_y)
	
	# init block positions
	var block_parents: Array[Node] = [Node.new(), Node.new()]
	for b in block_parents:
		root.add_child.call_deferred(b)
	
	for x in collums:
		for y in rows:
			for player in 2:
				var block: Block = block_scene.instantiate()
				var player_offset = player * center_x
				var x_pos = x * BLOCK_SIZE * game_scale.x + player_offset
				block.scale = game_scale
				block.position = Vector2(x_pos, y * BLOCK_SIZE * game_scale.y)
				block.set_line(line_colour)
				block.set_layer(player, colours[colours.size() - player - 1])
				block.name = str(player)
				block.hit.connect(flip_block)
				block_parents[player].add_child.call_deferred(block)
	
	# set players
	const x_padding = 128
	spawn_ball(0, Vector2(x_padding, center_y))
	spawn_ball(1, Vector2(center_x * 2 - x_padding, center_y))
	
	# set edge colliders
	var top_right = Vector2(center_x * 2, 0)
	var s_top = edge_colliders[0].shape as SegmentShape2D
	s_top.a = Vector2.ZERO
	s_top.b = top_right
	
	var bot_right = Vector2(center_x * 2, center_y * 2)
	var s_right = edge_colliders[1].shape as SegmentShape2D
	s_right.a = top_right
	s_right.b = bot_right
	
	var bot_left = Vector2(0, center_y * 2)
	var s_bot = edge_colliders[2].shape as SegmentShape2D
	s_bot.a = bot_right
	s_bot.b = bot_left
	
	var s_left = edge_colliders[3].shape as SegmentShape2D
	s_left.a = bot_left
	s_left.b = Vector2.ZERO


func spawn_ball(index: int,pos: Vector2) -> void:
		var ball: Ball = ball_scene.instantiate()
		ball.set_id(index, colours[index])
		ball.scale = game_scale
		ball.position = pos
		root.add_child.call_deferred(ball)
		var f = force if index % 2 == 0 else -force
		ball.launch(f)


func flip_block(block: Block) -> void:
	if block.prev_layer == 3:
		block.set_layer(1, colours[0])
	elif block.prev_layer == 4:
		block.set_layer(0, colours[1])

