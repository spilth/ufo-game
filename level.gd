class_name Level
extends Node

func _on_ufo_health_depleted():
	get_tree().reload_current_scene()
