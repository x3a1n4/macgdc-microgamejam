# MOST IMPORTANT PART!! We extend your microgame as a subclass of Microgame
# so that the main game can include it in the list of microgames and freely
# switch between them.
extends Microgame

@export var explosion : PackedScene

@onready var knight = $Knight
@onready var skeleton = $Skeleton
@onready var music = $Music

func _ready():
	# Second most important part! This calls Microgame's _ready() function
	# to prepare the bomb timer.
	super()
	
	await get_tree().create_timer(0.67).timeout
	music.play()


func win():
	win_game.emit()
	
func lose():
	lose_game.emit()

func create_explosion_at(thing : Node2D):
	var inst = explosion.instantiate() as Sprite2D
	add_child(inst)
	inst.position = thing.position

func _on_knight_sword_hit(body):
	if body == skeleton:
		create_explosion_at(skeleton)
		skeleton.queue_free()
		win()

func _on_knight_body_entered(body):
	if body == skeleton:
		create_explosion_at(knight)
		knight.queue_free()
		lose()
