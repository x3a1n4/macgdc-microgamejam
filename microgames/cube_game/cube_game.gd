extends Microgame

@export var num_cubes = 10
@export var explosion : PackedScene

var directions = [
	Vector3i.UP,
	Vector3i.DOWN,
	Vector3i.FORWARD,
	Vector3i.BACK,
	Vector3i.LEFT,
	Vector3i.RIGHT
]
const ITEMNUM = 1
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super()
	
	# spawn cubes
	# note: generation is almost for sure not working
	for i in range(num_cubes):
		var used_cells : Array[Vector3i] = $SubViewport/GridMap.get_used_cells_by_item(ITEMNUM)
		
		# get all adjacent cells
		var adjacent_cells = {}
		if !used_cells:
			used_cells = []
			adjacent_cells = {Vector3i.ZERO: null}
		else:
			for cell : Vector3i in used_cells:
				for direction in directions:
					adjacent_cells[cell + direction] = null
		
		adjacent_cells = adjacent_cells.keys()
		
		for cell : Vector3i in adjacent_cells:
			if cell in used_cells:
				adjacent_cells.erase(cell)
			
			if cell.length() > 7:
				adjacent_cells.erase(cell) # bit too far, don't add box here
		
		var position = adjacent_cells.pick_random()
		$SubViewport/GridMap.set_cell_item(position, ITEMNUM)
	
	# spawn buddy and flag
	var buddy_spawn = get_buddy_spawn($SubViewport/GridMap.get_used_cells_by_item(ITEMNUM))
	$SubViewport/Buddy.position = $SubViewport/GridMap.map_to_local(buddy_spawn) + Vector3.UP * $SubViewport/GridMap.cell_size.z / 2
	
	var flag_spawn = get_flag_spawn($SubViewport/GridMap.get_used_cells_by_item(ITEMNUM))
	$SubViewport/GridMap/Flag.position = $SubViewport/GridMap.map_to_local(flag_spawn) + Vector3.UP * $SubViewport/GridMap.cell_size.z / 2

func get_flag_spawn(cells : Array[Vector3i]) -> Vector3i:
	var output = cells.reduce(func(max, vec): return vec if -vec.x+vec.y/10-vec.z > -max.x+max.y/10-max.z else max)
	return output
	
func get_buddy_spawn(cells : Array[Vector3i]) -> Vector3i:
	var output = cells.reduce(func(max, vec): return vec if vec.x+vec.y/10+vec.z > max.x+max.y/10+max.z else max)
	return output

var axis : Vector3 = Vector3.ZERO
var start_pos : Vector3 = Vector3.ZERO
var prev_rotation = 0;
var rotating_down: bool = false
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# rotate!
	if get_node("SubViewport/Buddy"):
		if not $SubViewport/GridMap/RotationTimer.is_stopped():
			var progress = 1 - $SubViewport/GridMap/RotationTimer.time_left / $SubViewport/GridMap/RotationTimer.wait_time
			var transform_vec : Vector3 = start_pos - $SubViewport/Buddy.position
			
			var cur_rotation = lerpf(0, PI/2, progress)
			var transform_mod = lerp(Vector3.ZERO, Vector3.DOWN, progress)
			
			$SubViewport/GridMap.rotate(axis, cur_rotation - prev_rotation)
			$SubViewport/GridMap.position = transform_vec.rotated(axis, cur_rotation) + $SubViewport/Buddy.position
			if rotating_down:
				$SubViewport/GridMap.position += transform_mod
			
			prev_rotation = cur_rotation
		
		# update camera
		var current_looking : Vector3 = $SubViewport/Camera3D.project_position(Vector2(640/2, 360/2), $SubViewport/Camera3D.position.distance_to($SubViewport/Buddy.position))
		$SubViewport/Camera3D.look_at(lerp(current_looking, $SubViewport/Buddy.position, 0.5)) 
		
func _on_buddy_worldrotate(in_rotation: Vector2i, is_rotating_down: bool) -> void:
	print("Rotating!")
	in_rotation = Vector2(in_rotation).rotated(PI/2)
	print(in_rotation)
	
	axis = Vector3(in_rotation.x, 0, in_rotation.y)
	prev_rotation = 0 # hacky
	start_pos = $SubViewport/GridMap.position
	rotating_down = is_rotating_down
	
	$SubViewport/GridMap/RotationTimer.start()
	# disable collision
	#$SubViewport/GridMap.set_collision_layer_value(1, false)

func _on_rotation_timer_timeout() -> void:
	# end rotation 
	start_pos = $SubViewport/GridMap.position
	#$SubViewport/GridMap.set_collision_layer_value(1, true)

# if buddy touches the flag, win!
func _on_flag_body_entered(body: Node3D) -> void:
	if body.is_in_group("buddy"):
		win_game.emit()
		create_explosion_at(body)
		body.queue_free() # delete buddy
		
		# do win animation of some kind, TODO

func create_explosion_at(thing : Node3D):
	var inst = explosion.instantiate() as Sprite2D
	add_child(inst)
	inst.position = $SubViewport/Camera3D.unproject_position(thing.position)