extends Microgame

@export var moneybag_scene : PackedScene

@export var moneybag_amount = 3

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super() # call parent
	
	for i in range(moneybag_amount):
		var moneybag = moneybag_scene.instantiate() # make scene
		add_child(moneybag) # add child
		moneybag.position.x = randf_range(30, 560)
		moneybag.position.y = randf_range(30, 290)
