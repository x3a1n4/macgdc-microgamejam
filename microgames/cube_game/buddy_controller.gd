extends CharacterBody3D

const SPEED = 5.0
const JUMP_VELOCITY = 4.5

signal worldrotate

var input_dir : Vector2 = Vector2.ZERO

var jump_start_pos : Vector3

@export var grid : GridMap

func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		pass
	
	if is_on_floor():
		if $AnimationPlayer.current_animation == "Jump_Idle" or $AnimationPlayer.current_animation == "Jump":
			# play jump_land
			$AnimationPlayer.stop()
			$AnimationPlayer.play("Jump_Land")
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var last_input_dir = input_dir
	input_dir = Input.get_vector("keyboard_left", "keyboard_right", "keyboard_up", "keyboard_down")
	
	# see if we can jump
	var jump : bool = input_dir != Vector2.ZERO and input_dir != last_input_dir and $FloorCast.is_colliding()
	# TODO: handle buffering
	if jump:
		var direction : Vector2i = input_dir.normalized().rotated(PI).snapped(Vector2.ONE) # snap to UP, DOWN, LEFT, RIGHT
		var direction3 = Vector3(direction.x, 0, direction.y) # I will never remember that y is vertical here
		
		# face mesh in direction
		look_at(global_transform.origin + direction3, Vector3.UP)
		
		# jump
		$AnimationPlayer.play("Jump")
		$JumpSound.play()
		
		# if ray hit something, face that direction and rotate world
		$ForewardsCast.force_raycast_update()
		$ForewardsCast/DownwardsCast.force_raycast_update()
		if $ForewardsCast.is_colliding():
			print("rotate up")
			worldrotate.emit(direction, false)
		elif not $ForewardsCast/DownwardsCast.is_colliding():
			print("rotate down")
			worldrotate.emit(-direction, true)
			
		# else, just jump in that direction
		else:
			$JumpPath/JumpTimer.start()
			jump_start_pos = position
		
		#position = $FloorCast.get_collision_point() + Vector3.UP/2
		#snap_to_grid()
	
	# check if we're jumping
	if not $JumpPath/JumpTimer.is_stopped():
		# set jump position
		var jump_progress = 1 - $JumpPath/JumpTimer.time_left / $JumpPath/JumpTimer.wait_time
		
		$JumpPath/PathFollow3D.set_progress_ratio(jump_progress) 
		# position is not updated in time
		position = jump_start_pos + $JumpPath/PathFollow3D.get_position().rotated(Vector3.UP, rotation.y)

	move_and_slide()

func _on_jump_timer_timeout() -> void:
	$JumpPath/PathFollow3D.set_progress_ratio(0) # hack due to https://github.com/godotengine/godot/issues/95612

func _on_rotation_timer_timeout() -> void:
	snap_to_grid()

func snap_to_grid():
	var grid_pos = grid.local_to_map(grid.to_local(position))
	position = grid.to_global(grid.map_to_local(grid_pos))

# pseudo animation tree
func _on_animation_player_animation_finished(anim_name: StringName) -> void:
	# if jump
	if anim_name == "Jump":
		# play jump idle
		$AnimationPlayer.play("Jump_Idle")
	# if jump
	if anim_name == "Jump_Land":
		# play idle
		$AnimationPlayer.play("Idle")
	pass # Replace with function body.
