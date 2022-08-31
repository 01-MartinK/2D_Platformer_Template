extends KinematicBody2D

# enum for player states
enum STATES {GROUND,AIR,WALL,WATER}
var state = STATES.AIR

# child nodes for ease of reference
onready var left_wall_ray : RayCast2D = get_node("left_wall")
onready var right_wall_ray : RayCast2D = get_node("right_wall")
onready var floor_col_node : Node2D = get_node("floor_col")

# preloaded effects
onready var floor_slam_effect = preload("res://objects/vfx/ground_fall_particles.tscn")

# variables
const ACCEL : int = 500
const GRAVITY : float = 21.5

var move_speed : int = 48
var jump_strength : int = 32

var move_vec : Vector2 = Vector2.ZERO

var look_direction : int = 1
var wall_direction : int = 0

# on node scene ready
func _ready():
	Global.player = self
	add_to_group("player")

# updated on physics and process
func _physics_process(delta):
	ui_update() # update the ui
	
	# check if player is on ground
	var grounded = get_is_grounded()
	# get the player left right movement
	var x_input = (Input.get_action_strength("player_right") - Input.get_action_strength("player_left"))
	
	# smooth scale the player Sprite to the look_direction
	$Sprite.scale.x = lerp($Sprite.scale.x, look_direction, 0.25)
	
	match state:
		STATES.GROUND:
			if x_input != 0:
				look_direction = x_input
				if !$footstep_sfx.playing:
					$footstep_sfx.playing = true
			else:
				if $footstep_sfx.playing:
					$footstep_sfx.playing = false
			
			move_vec.x = lerp(move_vec.x, x_input * move_speed * delta * ACCEL, 0.25)
			
			if Input.is_action_pressed("player_jump"):
				move_vec.y -= jump_strength * 3
			
			if !grounded:
				_switch_state(STATES.AIR)
		STATES.AIR:
			move_vec.y += GRAVITY * delta * 64
			
			move_vec.x = lerp(move_vec.x, x_input * move_speed * delta * ACCEL, 0.025)
			
			if move_vec.y > 0:
				$Sprite.position = Vector2(0,0)
				$Sprite.rotation_degrees = lerp($Sprite.rotation_degrees, -15 * look_direction, 0.15)
			elif move_vec.y < 0:
				$Sprite.position = Vector2(0,0)
				$Sprite.rotation_degrees = lerp($Sprite.rotation_degrees, 15 * look_direction, 0.15)
			
			if grounded:
				squash_stretch(Vector2(-0.5  * move_vec.y / 600, 0.25 * move_vec.y / 600 ))
				_switch_state(STATES.GROUND)
				if move_vec.y > 480:
					_spawn_floor_slam_particle()
			elif left_wall_ray.is_colliding() and Input.is_action_pressed("player_left"):
				wall_direction = -1
				_switch_state(STATES.WALL)
				move_vec.y = move_vec.y / 2
			elif right_wall_ray.is_colliding() and Input.is_action_pressed("player_right"):
				wall_direction = 1
				_switch_state(STATES.WALL)
				move_vec.y = move_vec.y / 2
		STATES.WALL:
			move_vec.y += GRAVITY * delta * 16
			look_direction = -wall_direction
			
			$Sprite.rotation_degrees = 15 * look_direction
			$Sprite.position = Vector2(4 * -look_direction ,0)
			
			$wall_slide_particles.position = Vector2(16 * wall_direction, 0)
			$wall_slide_particles.emitting = true
			
			if Input.is_action_pressed("player_jump"):
				move_vec.x = move_speed * 7 * look_direction
				move_vec.y -= jump_strength * 4
			
			if grounded:
				_switch_state(STATES.GROUND)
			elif wall_direction == 1 and !right_wall_ray.is_colliding() or Input.is_action_just_released("player_left"):
				_switch_state(STATES.AIR)
			elif wall_direction == -1 and !left_wall_ray.is_colliding() or Input.is_action_just_released("player_right"):
				_switch_state(STATES.AIR)
	
	move_vec = move_and_slide(move_vec, Vector2.UP)

# update ui
func ui_update():
	$"%coin_amount_lbl".text = str(Global.coins)

# squash and stretch animation
func squash_stretch(amount : Vector2):
	var tween = create_tween().set_trans(Tween.TRANS_CIRC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property($Sprite, "scale", Vector2(1,1) - amount, .1)
	tween.parallel().tween_property($Sprite, "position", Vector2(0,8), .1)
	tween.tween_property($Sprite, "scale", Vector2(1, 1), .1)
	tween.parallel().tween_property($Sprite, "position", Vector2.ZERO, .1)

# spawn floor slam particles
func _spawn_floor_slam_particle():
	var b = floor_slam_effect.instance()
	b.global_position = global_position + Vector2(0,48)
	get_parent().add_child(b)

# switch state to new_state
func _switch_state(new_state):
	if state != new_state:
		state = new_state
		$wall_slide_particles.emitting = false
		$footstep_sfx.playing = false
		if new_state == STATES.GROUND:
			$Sprite.position = Vector2(0,0)
			$Sprite.rotation_degrees = 0

# check if is grounded if true return true
func get_is_grounded():
	for ray in floor_col_node.get_children():
		if ray.is_colliding():
			return true
	
	return false


func _play_coin_pickup_sound():
	$coin_pickup_sfx.play()
