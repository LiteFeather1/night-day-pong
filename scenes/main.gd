class_name Main
extends Node2D
 

signal redraw_blocks()


@onready var root: Window = get_tree().get_root()

@export_group("Camera")
@export var camera_2d: Camera2D
@export_range(0.0, 1.0) var sides_padding_percent: float = .6
@export_range(0.0, 1.0) var tops_padding_percent: float = .25
@export var camera_offset_y: float = 32

@export_group("Nodes")
@export var main_ui: MainUI
@export var edge_colliders: Array[CollisionShape2D]

@export_group("Game Settings")
@export var collums: int = 8
@export var rows: int = 8

@export_group("Colours")
@export var colours: Array[Color]
@export var line_colour: Color = Color("363636")
@export var background_colour: Color = Color("1e1e1e")

@export_group("Ball Settings")
const BALL_SCENE: PackedScene = preload("res://scenes/ball.tscn")
@export var ball_amount: int = 1
@export var ball_start_force: float = 2048
@export var ball_scale: float = .5
var parents_ball: Array[Node]
var balls: Array[Array] = [[], []]

@export var show_hit_particle: bool = true
const BALL_HIT_PARTICLE = preload("res://scenes/ball_hit_particle.tscn")
var ball_hit_particles: Array[BallHitParticle]
var parent_ball_hit_particle: Node

@export var show_ball_trail: bool = true
@export var gradient_ball_trail: Gradient
var trail_gradients: Array[Gradient]

@export_group("Block Settings")
const BLOCK_SCENE: PackedScene = preload("res://scenes/block.tscn")
var all_blocks: Array[Array] = [[], []]
@export var block_scale: float = 1.0
@export var scale_position: bool = true
const BLOCK_SIZE: int = 128
const HALF_BLOCK_SIZE: int = 64

var elapsed_time: float = 0.0

# variables
var scale_pos: float = 1.0 if !scale_position else block_scale
var center_x: float
var center_y: float


func _ready() -> void:
	RenderingServer.set_default_clear_color(background_colour)
	
	parent_ball_hit_particle = Node.new()
	parent_ball_hit_particle.set_name("parent_ball_hit_particle")
	root.add_child.call_deferred(parent_ball_hit_particle)
	for i in 2:
		# Spawn ball hit particles
		for _i in ball_amount:
			spawn_ball_hit_particle()
		
		# ball parents
		var parent_ball := Node.new()
		parent_ball.set_name("parent_ball_%d" % i)
		parents_ball.append(parent_ball)
		root.add_child.call_deferred(parent_ball)
		
		# duplicate gradients
		var g := gradient_ball_trail.duplicate()
		var c := colours[i]
		c.a = g.get_color(0).a
		g.set_color(0, c)
		g.set_color(1, colours[i])
		trail_gradients.append(g)
	
	place_blocks()


func _draw() -> void:
	var radius = HALF_BLOCK_SIZE * ball_scale
	for i in 2:
		var colour := colours[i]
		for j in balls[i].size():
			draw_circle(balls[i][j].position, radius, colour)


func _process(delta: float) -> void:
	elapsed_time += delta
	main_ui.set_time(elapsed_time)
	queue_redraw()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("screenshot"):
		var image := get_viewport().get_texture().get_image()
		var path := "Screenshots/screenshot_%s.png" % Time.get_datetime_string_from_system() \
				.replace("-", "_").replace(":", "_").replace("T", "_")
		image.save_png(path)


func start_game() -> void:
	for p in balls:
		for b: Ball in p:
			var theta := randf() * TAU
			var random_inside_unit_circle := Vector2(cos(theta), sin(theta)) * sqrt(randf())
			b.launch(random_inside_unit_circle.normalized() * ball_start_force)
	
	process_mode = Node.PROCESS_MODE_INHERIT

# This also repositions the camera and the edge colliders and replace the balls
func place_blocks() -> void:
	# init variables
	scale_pos = 1.0 if !scale_position else block_scale
	center_x = collums * BLOCK_SIZE * scale_pos
	center_y = rows * BLOCK_SIZE * 0.5 * scale_pos
	
	process_mode = Node.PROCESS_MODE_DISABLED
	for p in all_blocks:
		for b in p:
			b.queue_free()
		p.clear()
	process_mode = Node.PROCESS_MODE_INHERIT
	
	# set block
	for i in 2:
		var parent_block := Node.new()
		parent_block.set_name("block_parent_%d" % i)
		root.add_child.call_deferred(parent_block)
		var player_offset := i * center_x + HALF_BLOCK_SIZE * scale_pos
		for x in collums:
			for y in rows:
				var block: Block = BLOCK_SCENE.instantiate()
				var x_pos := x * BLOCK_SIZE * scale_pos + player_offset
				var y_pos := y * BLOCK_SIZE * scale_pos + HALF_BLOCK_SIZE * scale_pos
				block.position = Vector2(x_pos, y_pos)
				block.scale = Vector2(block_scale, block_scale)
				block.set_layer(i)
				block.set_name("block_%d_%d" % [i, x * collums + y])
				block.hit.connect(flip_block)
				
				all_blocks[i].append(block)
				
				parent_block.add_child.call_deferred(block)
		
		main_ui.set_score(i, all_blocks[i].size())
		main_ui.set_score_colour(i, colours[i])
	
	# camera zoom
	var block_width := center_x * 2.0
	var block_height := center_y * 2.0
	var viewport: Vector2i = get_viewport().get_size()
	var zoom_x := viewport.x / (block_width * (sides_padding_percent + 1))
	var size_y := block_height * (tops_padding_percent + 1)
	var zoom_y := viewport.y / size_y
	var zoom := zoom_x if zoom_y > zoom_x else zoom_y
	camera_2d.zoom = Vector2(zoom, zoom)
	
	# set camera pos
	var camera_pos_y := center_y + (camera_offset_y / zoom)
	camera_2d.position = Vector2(center_x, camera_pos_y)
	
	# set edge colliders
	var points := [
			center_x, 0.0, # Top 
			block_width, center_y, # Right
			center_x, block_height, # Bot 
			0.0, center_y] # left
	
	for i in edge_colliders.size():
		var i_point := i * 2
		edge_colliders[i].position = Vector2(points[i_point], points[i_point + 1])
	
	redraw_blocks.emit()
	
	place_balls()


func place_balls() -> void:
	for p in balls:
		for b in p:
			b.queue_free()
		p.clear()
	
	# set balls
	var ball_padding := BLOCK_SIZE * scale_pos
	var nearest_sqrt := pow(ceil(sqrt(ball_amount)), 2.0)
	# TODO: in the future it would be nice to have a grid that is not just squared,
	# One that respects the size of the ball area (collums & rows)
	var amount_per_col := int(sqrt(nearest_sqrt))
	var remainder := ball_amount % amount_per_col
	var amount_of_rows := floori(float(ball_amount) / amount_per_col)
	
	var center_x_1 := center_x * 0.5
	var min_x_1 := center_x_1 - ((amount_per_col - 1) / 2.0 * ball_padding)
	var min_y := center_y + ((amount_of_rows - 1) / 2.0 * ball_padding)
	
	if remainder > 0:
		min_y += ball_padding * .5

	var spawned := (amount_per_col - 1) * amount_per_col + amount_of_rows
	var y_ball_remainder_pos := min_y - (ball_padding * amount_of_rows)
	for i in 2:
		for x in amount_per_col:
			for y in amount_of_rows:
				var player_offset := center_x * i
				spawn_ball(
					x * amount_per_col + y, 
					i,
					Vector2(min_x_1 + (ball_padding * x) + player_offset,
					min_y - (ball_padding * y)))
		
		for r in remainder:
			var player_offset := ((ball_padding * remainder) + center_x) * i
			spawn_ball(
				spawned + r, 
				i,
				Vector2(min_x_1 + (ball_padding * r) + player_offset, 
				y_ball_remainder_pos))


func spawn_ball(num: int, index: int, pos: Vector2) -> void:
	var ball: Ball = BALL_SCENE.instantiate()
	ball.set_name("ball_%d" % num)
	ball.set_id(index)
	ball.trail.set_gradient(trail_gradients[index])
	ball.trail.set_state(show_ball_trail)
	ball.set_pos_scale(pos, ball_scale - (ball_scale * 0.05))
	ball.on_hit.connect(on_ball_hit)
	balls[index].append(ball)
	parents_ball[index].add_child.call_deferred(ball)


func on_ball_hit(hit_point: Vector2, normal: Vector2, id: int) -> void:
	if !show_hit_particle:
		return
	
	if ball_hit_particles.size() == 0:
		spawn_ball_hit_particle()
	
	ball_hit_particles.pop_front().play(hit_point, normal, colours[id])


func spawn_ball_hit_particle() -> void:
	var particle: BallHitParticle = BALL_HIT_PARTICLE.instantiate()
	particle.finished_playing.connect(return_ball_hit_particle)
	ball_hit_particles.append(particle)
	parent_ball_hit_particle.add_child.call_deferred(particle)


func return_ball_hit_particle(particle: BallHitParticle) -> void:
	ball_hit_particles.append(particle)


func flip_block(block: Block) -> void:
	var from := block.id
	var to := (block.id + 1) % 2
	
	block.set_layer(to)
	
	all_blocks[from].remove_at(all_blocks[from].find(block))
	all_blocks[to].append(block)
	
	main_ui.set_score(from, all_blocks[from].size())
	main_ui.set_score(to, all_blocks[to].size())
	
	redraw_blocks.emit()

