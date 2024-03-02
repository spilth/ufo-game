class_name Level
extends Node

@export var next_level: PackedScene

func _on_ufo_health_depleted():
	get_tree().reload_current_scene()


func _on_mothership_completed():
	get_tree().change_scene_to_packed(next_level)
