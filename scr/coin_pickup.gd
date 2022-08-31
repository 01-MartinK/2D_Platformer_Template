# Coin for collection
extends Area2D

func _ready():
	connect("body_entered",self,"on_body_entered") # connect the signals

# if a body has entered give a coin to the global variables
func on_body_entered(body):
	if body.is_in_group("player"):
		Global.coins += 1
		body._play_coin_pickup_sound()
		queue_free()
