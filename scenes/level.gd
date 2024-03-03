class_name Level
extends Node

@export_file("*.tscn") var next_level

func _on_ufo_health_depleted():
	get_tree().reload_current_scene()

func _on_mothership_completed():
	call_deferred("load_level", next_level)

func load_level(level_path:String):
	get_tree().change_scene_to_file(level_path)
