extends CharacterBody2D

@export var player : CharacterBody2D
@export var speed = 300

signal killed_player

func _physics_process(delta: float) -> void:
	
	if player != null:
		velocity = player.position - position
		velocity = velocity.normalized() * speed
	
	move_and_slide()
	

func _on_hurtbox_body_entered(body: Node2D) -> void:
	if body.is_in_group("mygame_player"):
		killed_player.emit() # kill the player
		body.queue_free() # delete player
