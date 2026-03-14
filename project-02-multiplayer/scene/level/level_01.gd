extends Node2D

var bat_scene = preload("res://obstacles/bat.tscn")
var ghost_scene = preload("res://obstacles/ghost.tscn")
var slime_scene = preload("res://obstacles/slime.tscn")
var golem_scene = preload("res://obstacles/golem.tscn")

var obstacle_types := [ghost_scene, slime_scene]
var obstacles: Array
var bat_heights := [390, 450] #[250, 390] - previous height

#game variables
const PLAYER_START_POS := Vector2i(100, 485)
const P2_START_POS := Vector2i(250, 485)
const CAM_START_POS := Vector2i(576, 324)
var difficulty
const MAX_DIFFICULTY : int = 2
var score : int
const SCORE_MODIFIER : int = 10
var high_score : int
var speed: float
const START_SPEED: float = 10.0
const SPEED_MODIFIER : int = 5000
const MAX_SPEED : int = 25
var screen_size : Vector2i
var ground_height : int
var game_running : bool
var last_obs

var level2_message_shown = false

# Called when the node enters the scene tree for the first time.
func _ready():
	screen_size = get_window().size
	ground_height = $Ground.get_node("Sprite2D").texture.get_height()
	$GameOver.get_node("Button").pressed.connect(new_game)

	$Player.jump_action = "p1_jump"
	$Player.duck_action = "p1_down"

	$Player2.jump_action = "p2_jump"
	$Player2.duck_action = "p2_down"

	new_game()

func new_game():
	score = 0
	show_score()
	game_running = false
	get_tree().paused = false
	difficulty = 0
	level2_message_shown = false

	for obs in obstacles:
		obs.queue_free()
	obstacles.clear()

	$Player.position = PLAYER_START_POS
	$Player.velocity = Vector2i(0, 0)
	$Player.show()
	$Player.process_mode = Node.PROCESS_MODE_INHERIT

	$Player2.position = P2_START_POS
	$Player2.velocity = Vector2(0, 0)
	$Player2.show()
	$Player2.process_mode = Node.PROCESS_MODE_INHERIT

	$Camera2D.position = CAM_START_POS
	$Ground.position = Vector2i(0, 0)

	$HUD.get_node("StartLabel").show()
	$LevelUp.hide()
	$GameOver.hide()

func _process(delta):
	if game_running:
		speed = START_SPEED + score / SPEED_MODIFIER
		if speed > MAX_SPEED:
			speed = MAX_SPEED
		adjust_difficulty()

		generate_advanced_obs()

		$Camera2D.position.x += START_SPEED
		for p in [$Player, $Player2]:
			if p.process_mode != Node.PROCESS_MODE_DISABLED:
				p.position.x += START_SPEED
				# Check if player fell off the left side of the screen
				if p.position.x < ($Camera2D.position.x - screen_size.x / 2):
					kill_player(p)

		score += speed
		show_score()

		if $Camera2D.position.x - $Ground.position.x > screen_size.x * 1.5:
			$Ground.position.x += screen_size.x
			
		for obs in obstacles: 
			if obs.position.x < ($Camera2D.position.x - screen_size.x):
				remove_obs (obs)
	else:
		if Input.is_action_pressed("ui_accept"):
			game_running = true
			$HUD.get_node("StartLabel").hide()

func generate_advanced_obs():
	# Only spawn if there is enough space since the last obstacle
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		# Decide WHAT to spawn
		var spawn_roll = randi() % 100
		# LEVEL 2 LOGIC: 20% chance to spawn the Stalker instead of regular traps
		if difficulty == MAX_DIFFICULTY and spawn_roll < 25:
			spawn_golem()
		else:
			generate_obs()

func generate_obs():
	if obstacles.is_empty() or last_obs.position.x < score + randi_range(300, 500):
		var obs_type = obstacle_types[randi() % obstacle_types.size()]
		var obs
		var max_obs = difficulty + 1
		for i in range(randi() % max_obs + 1):
			obs = obs_type.instantiate()
			var sprite = obs.get_node("AnimatedSprite2D")
			var tex = sprite.sprite_frames.get_frame_texture(sprite.animation, 0)
			var obs_height = tex.get_height()
			var obs_scale = sprite.scale
			var obs_x : int = screen_size.x + score + 100 + (i * 100)
			var obs_y : int = screen_size.y - ground_height - (obs_height * obs_scale.y / 2) + 210
			last_obs = obs
			add_obs(obs, obs_x, obs_y)
		if difficulty == MAX_DIFFICULTY:
			if (randi() % 2) == 0:
				obs = bat_scene.instantiate()
				var obs_x : int = screen_size.x + score + 100 
				var obs_y: int = bat_heights [randi() % bat_heights.size()]
				add_obs (obs, obs_x, obs_y)

func add_obs(obs, x, y):
	obs.position = Vector2i(x, y)
	obs.body_entered.connect(hit_obs)
	add_child(obs)
	obstacles.append(obs)

func remove_obs(obs):
	obs.queue_free()
	obstacles.erase(obs)

func spawn_golem():
	var golem = golem_scene.instantiate()
	var golem_x : int = screen_size.x + score + 400
	var golem_y : int = 440
	last_obs = golem
	add_obs(golem, golem_x, golem_y)

func hit_obs(body):
	if body is CharacterBody2D: # Check if it's a player
		kill_player(body)

func kill_player(player):
	player.hide()
	# Stop the player from processing logic/collisions
	player.process_mode = Node.PROCESS_MODE_DISABLED 
	
	# If BOTH players are now dead, trigger Game Over
	if $Player.process_mode == Node.PROCESS_MODE_DISABLED and \
	   $Player2.process_mode == Node.PROCESS_MODE_DISABLED:
		game_over()

func show_score():
	$HUD.get_node("ScoreLabel").text = "SCORE: " + str(score / SCORE_MODIFIER)

func check_high_score():
	if score > high_score:
		high_score = score
		$HUD.get_node("HighScoreLabel").text = "HIGH SCORE: " + str(score / SCORE_MODIFIER)

func show_level_message():
	$LevelUp.show()
	var label = $LevelUp.get_node("level_message")
	label.show()

	await get_tree().create_timer(3).timeout
	
	label.hide()
	$LevelUp.hide()

func adjust_difficulty():
	difficulty = (score / 2) / SPEED_MODIFIER
	if difficulty > MAX_DIFFICULTY:
		difficulty = MAX_DIFFICULTY

	if difficulty == MAX_DIFFICULTY and not level2_message_shown:
			show_level_message()
			level2_message_shown = true

func game_over():
	check_high_score()
	get_tree().paused = true
	game_running = false
	$GameOver.show()
