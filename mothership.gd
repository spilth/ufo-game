class_name Mothership
extends Area2D

signal satisfied
signal completed

@onready var tally_label = $TallyLabel

@export var humans_needed: int = 5

var humans_consumed = 0
var full = false

func _ready():
	update_label()

func consume_human():
	humans_consumed += 1
	update_label()

	if humans_consumed >= humans_needed:
		full = true
		satisfied.emit()

func update_label():
	tally_label.text = str(humans_consumed, "/", humans_needed)


func _on_body_entered(body):
	if body.name == "UFO":
		if full:
			completed.emit()
		else:
			print('Not full!')
			
