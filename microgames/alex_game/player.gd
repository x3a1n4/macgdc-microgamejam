extends CharacterBody2D

@export var SPEED = 300.0

@onready var sprite := $AnimatedSprite2D

func _physics_process(delta: float) -> void:

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var x_direction := Input.get_axis("keyboard_left", "keyboard_right")
	var y_direction := Input.get_axis("keyboard_up", "keyboard_down")
	if x_direction:
		velocity.x = x_direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		
	if y_direction:
		velocity.y = y_direction * SPEED
	else:
		velocity.y = move_toward(velocity.y, 0, SPEED)
	
	# flip sprite
	if velocity.x < 0:
		sprite.flip_h = true
	if velocity.x > 0:
		sprite.flip_h = false
	
	# play run
	if velocity.length() > 0:
		sprite.play("run")
	else:
		sprite.play("default")

	move_and_slide()
