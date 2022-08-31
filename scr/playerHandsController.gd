extends Node2D

# variables to ready on start of the scene
onready var arrow = preload("res://objects/arrow.tscn")
onready var hands_animation_player = $"hands_animation_player"

# booleans
var aiming : bool = false
var reset_rotation : bool = false

func _process(delta):
	
	# check if animation playing or not or what that animation is
	if !hands_animation_player.is_playing() or hands_animation_player.current_animation == "idle":
		if Input.is_action_just_pressed("primary_mouse"): # check mouse primary input
			aiming = true
			reset_rotation = false
			hands_animation_player.play("ready_fire", 0.15)
	if hands_animation_player.current_animation == "ready_fire": # check animation name
		if Input.is_action_just_released("primary_mouse"): # check mouse secondary input
			aiming = false
			$rotation_reset_tmr.start(.6)
			hands_animation_player.play("fire")
	
	if aiming: # is aiming look at mouse
		look_at(get_global_mouse_position())
	else: # if isn't lerp to 0 rotation
		if reset_rotation: # if can reset rotation
			rotation = lerp_angle(rotation, deg2rad(0), 0.05)

# reset rotation timer timeout function
func _on_Timer_timeout():
	reset_rotation = true
	hands_animation_player.play("idle", 0.15)

# spawn the arrow via code
func spawn_arrow():
	randomize()
	get_parent().get_parent().get_node("arrow_fire_sfx").pitch_scale = rand_range(1.35,1.75)
	get_parent().get_parent().get_node("arrow_fire_sfx").play()
	var b = arrow.instance()
	b.position = $weapon.global_position
	b._add_velocity(global_position.direction_to($weapon.global_position) * 1250)
	# add the arrow to the scene
	get_parent().get_parent().get_parent().add_child(b)
