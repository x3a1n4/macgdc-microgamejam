extends Microgame

@export var moneybag_scene : PackedScene
@export var explosion : PackedScene
@export var player : CharacterBody2D
@export var goblin : CharacterBody2D
@export var moneybag_amount = 3
var counter = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	super() # call parent
	
	for i in range(moneybag_amount):
		var moneybag = moneybag_scene.instantiate() # make scene
		add_child(moneybag) # add child
		moneybag.position.x = randf_range(30, 560)
		moneybag.position.y = randf_range(30, 290)
		
		moneybag.player_picked_up.connect(_on_player_picked_up_bag()) #don't work

func _on_goblin_killed_player() -> void:
	lose_game.emit()
	create_explosion_at(player)

func _on_player_picked_up_bag():
	counter += 1
	if counter == moneybag_amount:
		win_game.emit()
		create_explosion_at(goblin)

func create_explosion_at(thing : Node2D):
	var inst = explosion.instantiate() as Sprite2D
	add_child(inst)
	inst.position = thing.position
