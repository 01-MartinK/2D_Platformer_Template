extends AudioStreamPlayer2D

func _ready():
	connect("finished",self,"finished")
	play()

# kill on audio finished
func finished():
	queue_free()
