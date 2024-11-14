extends CharacterBody2D

@export var player : CharacterBody2D
@export var speed = 300

func _physics_process(delta: float) -> void:
	
	if(player):
		velocity = player.position - position
		velocity = velocity.normalized() * speed
	
	move_and_slide()
