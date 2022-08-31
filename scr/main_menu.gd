extends Control

onready var option_menu = $option_menu

func _ready():
	$"%options_close_btn".connect("pressed",self,"_hide_options_menu")

func _on_play_btn_pressed():
	get_tree().change_scene_to(load("res://scenes/template_game_scene.tscn"))

func _on_options_btn_pressed():
	_show_options_menu()

func _on_quit_btn_pressed():
	get_tree().quit()

func _show_options_menu():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(option_menu, "rect_position", Vector2.ZERO, 0.5)

func _hide_options_menu():
	var tween = create_tween().set_ease(Tween.EASE_IN_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(option_menu, "rect_position", Vector2(0,600), 0.5)

func _on_audio_slider_drag_ended(value_changed):
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), value_changed)
