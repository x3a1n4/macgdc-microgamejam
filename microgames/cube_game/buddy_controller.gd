extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

signal worldrotate

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if is_on_floor()
		# play jump_land
		$AnimationPlayer.play("Jump_Land")
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir := Input.get_vector("keyboard_left", "keyboard_right", "keyboard_up", "keyboard_down")
	# TODO: handle buffering
	if input_dir != Vector2.ZERO and is_on_floor():
		var direction : Vector2i = input_dir.normalized().snapped(Vector2.ONE) # snap to UP, DOWN, LEFT, RIGHT
		var direction3 = Vector3(direction.x, direction.y, 0)
		# cast ray in input dir
		$RayCast3D.target_position = direction3
		
		# face mesh in direction
		look_at(global_transform.origin + direction3, Vector3.UP)
		
		# jump
		$AnimationPlayer.play("Jump")
		
		# if ray hit something, face that direction and rotate world
		if $RayCast3D.is_colliding():
			worldrotate.emit(direction)

	move_and_slide()

# pseudo animation tree
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# if jump
	if anim_name == "Jump":
		# play jump idle
		$AnimationPlayer.play("Jump_Idle")
	# if jump
	if anim_name == "Jump_Idle":
		# play idle
		$AnimationPlayer.play("Idle")
	pass # Replace with function body.
