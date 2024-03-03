extends Control

@export_file("*.tscn") var first_level

func _on_play_again_button_pressed():
	get_tree().change_scene_to_file(first_level)

func _on_quit_button_pressed():
	get_tree().quit()
