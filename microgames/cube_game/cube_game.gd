extends Microgame

@export var num_cubes = 10

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
			
			if cell.length() < 5:
				adjacent_cells.erase(cell) # bit too far, don't add box here
		
		var position = adjacent_cells.pick_random()
		$SubViewport/GridMap.set_cell_item(position, ITEMNUM)
	
	# spawn buddy and flag

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
