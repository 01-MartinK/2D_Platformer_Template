# Arrow script for the arrow object
# used for shooting at different objects or enemies
extends KinematicBody2D

onready var arrow_hit_sfx = preload("res://objects/sfx/arrow_hit_sfx.tscn")

# raycast
onready var ray_cast_2d = $RayCast2D

# gravity
const GRAVITY = 21.5
const GRAVITY_MULTIPLIER = 64

# velocity for movement of object
var velocity : Vector2 = Vector2.ZERO

# add velocity via external or internal factors
func _add_velocity(velocity_value : Vector2):
	velocity = velocity_value
	$Sprite.rotation = velocity.angle()

func _physics_process(delta):
	# add gravity to velocity
	velocity.y += GRAVITY * delta * GRAVITY_MULTIPLIER
	
	# rotate arrow toward velocity
	$Sprite.rotation = velocity.angle()
	ray_cast_2d.rotation = velocity.angle()
	
	# check if the raycast is colliding
	if ray_cast_2d.is_colliding():
		ray_cast_2d.enabled = false
		var b = arrow_hit_sfx.instance()
		b.position = global_position
		get_parent().add_child(b)
		queue_free() # if it is kill the arrow
	
	# the use of velocity
	velocity = move_and_slide(velocity, Vector2.UP)
