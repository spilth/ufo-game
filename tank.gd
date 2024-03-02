extends Node2D

const DAMAGE = 20

@onready var ray_cast_2d: RayCast2D = $Cannon/RayCast2D
@onready var laser_line: Line2D = $Cannon/LaserLine
@onready var laser_sound: AudioStreamPlayer2D = $LaserSound
@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready():
	laser_line.visible = false

func _process(delta: float) -> void:
	if ray_cast_2d.is_colliding():
		laser_line.visible = true
		var collider = ray_cast_2d.get_collider()
		if collider.name == "UFO":
			collider.take_damage(DAMAGE * delta)
		
		if not laser_sound.playing:
			laser_sound.play()
			animation_player.pause()

	else:
		laser_line.visible = false
		if laser_sound.playing:
			laser_sound.stop()
			animation_player.play()


func _on_area_2d_body_entered(body):
	pass # Replace with function body.


func _on_area_2d_body_exited(body):
	pass # Replace with function body.
