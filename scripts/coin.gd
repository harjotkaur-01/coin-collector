extends Area2D


signal collected


func _ready():
	body_entered.connect(_on_body_entered)


func _on_body_entered(body):

	# Only the Player can collect coins
	if body.is_in_group("player"):

		collected.emit()

		queue_free()
