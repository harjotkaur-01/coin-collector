extends Node2D


# ==========================================
# GAME SETTINGS
# ==========================================

var current_level: int = 1
var max_level: int = 5

var score: int = 0
var coins_this_level: int = 0

var game_is_over: bool = false
var level_changing: bool = false


# ==========================================
# COIN SCENE
# ==========================================

var coin_scene = preload("res://scenes/coin.tscn")


# ==========================================
# NODE REFERENCES
# ==========================================

@onready var player = $Player
@onready var enemy = $Enemy
@onready var coin_container = $CoinContainer

@onready var score_label = $UI/ScoreLabel
@onready var level_label = $UI/LevelLabel
@onready var win_label = $UI/WinLabel
@onready var next_level_label = $UI/NextLevelLabel
@onready var restart_button = $UI/RestartButton


# ==========================================
# GAME START
# ==========================================

func _ready():

	game_is_over = false
	level_changing = false

	win_label.visible = false
	next_level_label.visible = false
	restart_button.visible = false

	# Allow button to receive keyboard input
	restart_button.focus_mode = Control.FOCUS_ALL

	# Mouse click
	restart_button.pressed.connect(_on_restart_pressed)

	start_level()


# ==========================================
# SPACE / ENTER RESTART
# ==========================================

func _unhandled_input(event):

	if event.is_action_pressed("ui_accept"):

		if game_is_over:

			_on_restart_pressed()


# ==========================================
# START LEVEL
# ==========================================

func start_level():

	game_is_over = false
	level_changing = false

	score = 0

	player.set_physics_process(true)
	player.set_process(true)

	if enemy:

		enemy.set_physics_process(true)
	enemy.set_process(true)

	win_label.visible = false
	next_level_label.visible = false
	restart_button.visible = false

	coins_this_level = current_level * 5

	level_label.text = "Level: " + str(current_level)

	update_score()

	if enemy:

		enemy.speed = 80.0 + (current_level * 20.0)

		spawn_enemy()

	create_coins()


# ==========================================
# SPAWN ENEMY
# ==========================================

func spawn_enemy():

	var left = 60.0
	var right = 740.0

	var top = 130.0
	var bottom = 540.0

	var enemy_position = Vector2.ZERO

	var valid_position = false

	var attempts = 0


	while not valid_position and attempts < 200:

		enemy_position = Vector2(
			randf_range(left, right),
			randf_range(top, bottom)
		)

		valid_position = true

		if enemy_position.distance_to(player.position) < 250.0:

			valid_position = false

		attempts += 1


	if valid_position:

		enemy.position = enemy_position


# ==========================================
# CREATE COINS
# ==========================================

func create_coins():

	for old_coin in coin_container.get_children():

		old_coin.queue_free()


	var left = 60.0
	var right = 740.0

	var top = 130.0
	var bottom = 540.0

	var player_distance = 100.0
	var enemy_distance = 100.0
	var coin_distance = 70.0

	var used_positions: Array[Vector2] = []


	for i in range(coins_this_level):

		var new_coin = coin_scene.instantiate()

		var random_position = Vector2.ZERO

		var valid_position = false

		var attempts = 0


		while not valid_position and attempts < 200:

			random_position = Vector2(
				randf_range(left, right),
				randf_range(top, bottom)
			)

			valid_position = true


			# Distance from player
			if random_position.distance_to(player.position) < player_distance:

				valid_position = false


			# Distance from enemy
			if valid_position:

				if random_position.distance_to(enemy.position) < enemy_distance:

					valid_position = false


			# Distance from other coins
			if valid_position:

				for old_position in used_positions:

					if random_position.distance_to(old_position) < coin_distance:

						valid_position = false

						break


			attempts += 1


		if valid_position:

			new_coin.position = random_position

			coin_container.add_child(new_coin)

			used_positions.append(random_position)

			new_coin.collected.connect(_on_coin_collected)

		else:

			new_coin.queue_free()


# ==========================================
# COIN COLLECTED
# ==========================================

func _on_coin_collected():

	if game_is_over:
		return

	if level_changing:
		return

	score += 1

	update_score()

	if score >= coins_this_level:

		level_complete()


# ==========================================
# UPDATE SCORE
# ==========================================

func update_score():

	score_label.text = "Coins: " + str(score) + " / " + str(coins_this_level)


# ==========================================
# STOP ALL MOVEMENT
# ==========================================

func stop_game_movement():

	player.velocity = Vector2.ZERO

	player.set_physics_process(false)
	player.set_process(false)


	if enemy:

		enemy.velocity = Vector2.ZERO

		enemy.set_physics_process(false)
		enemy.set_process(false)


# ==========================================
# LEVEL COMPLETE
# ==========================================

func level_complete():

	if game_is_over:
		return

	if level_changing:
		return

	level_changing = true

	stop_game_movement()


	for old_coin in coin_container.get_children():

		old_coin.queue_free()


	next_level_label.text = "LEVEL COMPLETE!"

	next_level_label.visible = true


	await get_tree().create_timer(2.0).timeout


	next_level_label.visible = false


	if current_level >= max_level:

		game_complete()

		return


	current_level += 1

	start_level()


# ==========================================
# GAME COMPLETE
# ==========================================

func game_complete():

	game_is_over = true
	level_changing = true

	stop_game_movement()

	win_label.text = "YOU WIN!"

	win_label.visible = true

	restart_button.visible = true


# ==========================================
# GAME OVER
# ==========================================

func game_over():

	if game_is_over:
		return

	game_is_over = true
	level_changing = true

	stop_game_movement()


	for old_coin in coin_container.get_children():

		old_coin.queue_free()


	win_label.text = "GAME OVER!"

	win_label.visible = true

	restart_button.visible = true


# ==========================================
# RESTART
# ==========================================

func _on_restart_pressed():

	current_level = 1

	score = 0

	coins_this_level = 0

	game_is_over = false
	level_changing = false

	win_label.visible = false
	next_level_label.visible = false
	restart_button.visible = false

	start_level()
	
