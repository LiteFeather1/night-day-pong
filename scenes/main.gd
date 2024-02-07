extends Node2D
 
@onready var root: Window = get_tree().get_root()

@export_group("Camera")
@export var camera_2d: Camera2D
@export_range(0.0, 1.0) var sides_padding_percent: float = .66
@export_range(0.0, 1.0) var tops_padding_percent: float = .25
@export var camera_offset_y: float = 24

@export_group("Nodes")
@export var main_ui: MainUI
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
@export var ball_amount: int = 1
@export var ball_start_force: float = 2048
@export var ball_scale: float = .5

@export var show_hit_particle: bool = true
const BALL_HIT_PARTICLE = preload("res://scenes/ball_hit_particle.tscn")
var ball_hit_particles: Array[BallHitParticle]

@export var gradient_ball_trail: Gradient
var trail_gradients: Array[Gradient]

@export_group("Block Settings")
const block_scene: PackedScene = preload("res://scenes/block.tscn")
var all_blocks: Array[Array] = [[], []]
@export var block_scale: float = 1.0
@export var scale_position: bool = false
const BLOCK_SIZE: int = 128
const HALF_BLOCK_SIZE: int = 64

var elapsed_time: float = 0.0


func _ready() -> void:
	# set clear colourt
	RenderingServer.set_default_clear_color(background_colour)
	
	# set trail gradients
	var block_parents: Array[Node] = [Node.new(), Node.new()]
	for i in 2:
		var g: Gradient = gradient_ball_trail.duplicate()
		var c = colours[i]
		c.a = 0
		g.set_color(0, c)
		g.set_color(1, colours[i])
		trail_gradients.append(g)
		
		root.add_child.call_deferred(block_parents[i])
		
		main_ui.set_score(i, collums * rows)
	
	var scale_pos = 1.0 if !scale_position else block_scale
	var center_x = collums * BLOCK_SIZE * scale_pos
	var center_y = rows * BLOCK_SIZE * 0.5 * scale_pos
	
	# camera zoom
	var block_width = center_x * 2.0
	var block_height = center_y * 2.0
	var viewport = get_viewport().size
	var zoom_x = viewport.x / (block_width * (sides_padding_percent + 1))
	var size_y = block_height * (tops_padding_percent + 1)
	var zoom_y = viewport.y / size_y
	var zoom = zoom_x if zoom_y > zoom_x else zoom_y
	camera_2d.zoom = Vector2(zoom, zoom)
	
	# set camera pos
	var camera_pos_y = center_y + (camera_offset_y / zoom)
	camera_2d.position = Vector2(center_x, camera_pos_y)
	
	# init block positions
	for x in collums:
		for y in rows:
			for i in 2:
				var block: Block = block_scene.instantiate()
				var player_offset = i * center_x + HALF_BLOCK_SIZE * scale_pos
				var x_pos = x * BLOCK_SIZE * scale_pos + player_offset
				block.position = Vector2(x_pos, y * BLOCK_SIZE * scale_pos + HALF_BLOCK_SIZE * scale_pos)
				block.scale = Vector2(block_scale, block_scale)
				block.set_line(line_colour)
				block.set_layer(i, colours[colours.size() - i - 1])
				block.name = str(i)
				block.hit.connect(flip_block)
				
				all_blocks[i].append(block)
				
				block_parents[i].add_child.call_deferred(block)
	
	# set balls
	var ball_padding = BLOCK_SIZE * ball_scale * 2.0
	var nearest_sqrt = pow(ceil(sqrt(ball_amount)), 2.0)
	# TODO: in the future it would be nice to have a grid that is not just squared,
	# One that respects the size of the ball area (collums & rows)
	var amount_of_colls = int(sqrt(nearest_sqrt))
	var amount_per_col = amount_of_colls
	var remainder = ball_amount % amount_per_col
	var amount_of_rows = floori(float(ball_amount) / amount_per_col)
	
	var center_x_1 = center_x * 0.5
	var min_x_1 = center_x_1 - ((amount_per_col - 1) / 2.0 * ball_padding)
	var min_y = center_y + ((amount_of_rows - 1) / 2.0 * ball_padding)
	
	if remainder > 0:
		min_y += ball_padding * .5
	
	for x in amount_per_col:
		for y in amount_of_rows:
			var x_pos = min_x_1 + (ball_padding * x)
			var y_pos = min_y - (ball_padding * y)
			spawn_ball(0, Vector2(x_pos, y_pos))
			spawn_ball(1, Vector2(x_pos + center_x, y_pos))
	
	var x_max_2 = min_x_1 + (ball_padding * remainder) + center_x
	for r in remainder:
		var x_pos = min_x_1 + (ball_padding * r)
		var y_pos = min_y - (ball_padding * amount_of_rows)
		spawn_ball(0, Vector2(x_pos, y_pos))
		spawn_ball(1, Vector2(x_max_2 - (ball_padding * r), y_pos))
	
	# Spawn ball hit particles
	for i in 11:
		spawn_ball_hit_particle();
	
	# set edge colliders
	var top_right = Vector2(block_width, 0.0)
	var s_top = edge_colliders[0].shape as SegmentShape2D
	s_top.a = Vector2.ZERO
	s_top.b = top_right
	
	var bot_right = Vector2(block_width, block_height)
	var s_right = edge_colliders[1].shape as SegmentShape2D
	s_right.a = top_right
	s_right.b = bot_right
	
	var bot_left = Vector2(0, block_height)
	var s_bot = edge_colliders[2].shape as SegmentShape2D
	s_bot.a = bot_right
	s_bot.b = bot_left
	
	var s_left = edge_colliders[3].shape as SegmentShape2D
	s_left.a = bot_left
	s_left.b = Vector2.ZERO


func _process(delta: float) -> void:
	elapsed_time += delta
	main_ui.set_time(elapsed_time)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("screenshot"):
		var image = get_viewport().get_texture().get_image()
		var path = "Screenshots/screenshot_%s.png" % Time.get_datetime_string_from_system() \
				.replace("-", "_").replace(":", "_").replace("T", "_")
		image.save_png(path)


func spawn_ball(index: int, pos: Vector2) -> void:
	var ball: Ball = ball_scene.instantiate()
	ball.set_id(index, colours[index])
	ball.set_trail_gradient(trail_gradients[index])
	ball.set_pos_scale(pos, ball_scale)
	ball.on_hit.connect(on_ball_hit)
	ball.launch(random_inside_unit_circle().normalized() * ball_start_force)
	root.add_child.call_deferred(ball)


func on_ball_hit(hit_point: Vector2, normal: Vector2, colour: Color):
	if !show_hit_particle:
		return
	
	if ball_hit_particles.size() == 0:
		spawn_ball_hit_particle()
	
	var particle: BallHitParticle = ball_hit_particles.pop_front()
	particle.position = hit_point
	particle.direction = normal
	particle.color = colour
	particle.emitting = true


func spawn_ball_hit_particle():
	var particle: BallHitParticle = BALL_HIT_PARTICLE.instantiate()
	particle.finished_playing.connect(return_ball_hit_particle)
	ball_hit_particles.append(particle)
	root.add_child.call_deferred(particle)


func return_ball_hit_particle(particle: BallHitParticle):
	ball_hit_particles.append(particle)


func random_inside_unit_circle() -> Vector2:
	var theta = randf() * 2.0 * PI
	return Vector2(cos(theta), sin(theta)) * sqrt(randf())


func flip_block(block: Block) -> void:
	if block.prev_layer == 3:
		block.set_layer(1, colours[0])
		remove_add_block(0, 1, block)
	elif block.prev_layer == 4:
		block.set_layer(0, colours[1])
		remove_add_block(1, 0, block)
	
	for i in 2:
		main_ui.set_score(i, all_blocks[i].size())


func remove_add_block(from: int, to: int, block: Block) -> void:
	# TODO Consider giving an index to the blocks
	all_blocks[from].remove_at(all_blocks[from].find(block))
	all_blocks[to].append(block)
