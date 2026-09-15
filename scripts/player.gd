extends CharacterBody2D

@export var speed: float = 300.0


func _physics_process(delta):

	var direction = Input.get_vector(
		"move_left",
		"move_right",
		"move_up",
        "move_down"
	)

	velocity = direction * speed

	move_and_slide()

	check_wall_collision()


func check_wall_collision():

	for i in get_slide_collision_count():

		var collision = get_slide_collision(i)

		var object = collision.get_collider()

		if object.is_in_group("walls"):

			var main = get_parent()

			if main.has_method("game_over"):

				main.game_over()
