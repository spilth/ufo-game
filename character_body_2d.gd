extends CharacterBody2D

const SPEED = 150.0
const ENERGY_DRAIN_RATE = 20
const ENERGY_RECHARGE_RATE = 25
const ENERGY_MAX = 100

@onready var beam = $Beam
@onready var beam_collider = $Beam/CollisionShape2D
@onready var chomper_collider = $Chomper/CollisionShape2D
@onready var beam_sound = $Beam/BeamSound
@onready var energy_line: Line2D = $EnergyLine

var energy = ENERGY_MAX

func _ready():
	beam.visible = false
	beam_collider.disabled = true
	chomper_collider.disabled = true

func _physics_process(delta):
	if Input.is_action_just_pressed("beam"):
		beam_sound.play()

	if Input.is_action_just_released("beam"):
		beam_sound.stop()

	if Input.is_action_pressed("beam") && energy > 0:
		beam.visible = true
		beam_collider.disabled = false
		chomper_collider.disabled = false
		energy -= ENERGY_DRAIN_RATE * delta

		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)
	else:
		beam.visible = false
		beam_collider.disabled = true
		chomper_collider.disabled = true
		if energy < ENERGY_MAX:
			energy += ENERGY_RECHARGE_RATE * delta

		var direction = Input.get_axis("left", "right")
		if direction:
			velocity.x = direction * SPEED
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		var direction2 = Input.get_axis("up", "down")
		if direction2:
			velocity.y = direction2 * SPEED
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)

	energy_line.width = 52 * energy / ENERGY_MAX

	move_and_slide()


func _on_chomper_body_entered(body):
	if body.is_in_group("Consumable"):
		body.queue_free()
