extends Particles2D

# start particle kill timer
func _ready():
	emitting = true
	$Timer.start(lifetime + 0.5)
	$Timer.connect("timeout", self, "_timeout")

# free the particle
func _timeout():
	queue_free()
