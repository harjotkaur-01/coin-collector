extends CharacterBody2D


@export var speed: float = 100.0

var player: CharacterBody2D


func _ready():

	player = get_tree().get_first_node_in_group("player")


func _physics_process(_delta):

	if player == null:
		return


	var main = get_parent()


	if main.game_is_over:

		velocity = Vector2.ZERO

		return


	# Chase player
	var direction = global_position.direction_to(
		player.global_position
	)

	velocity = direction * speed

	move_and_slide()


func _on_attack_area_body_entered(body):

	if body.is_in_group("player"):

		var main = get_parent()

		main.game_over()
