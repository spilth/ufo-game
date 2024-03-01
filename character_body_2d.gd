extends CharacterBody2D

const SPEED = 150.0
const ENERGY_DRAIN_RATE = 20
const ENERGY_RECHARGE_RATE = 20
const ENERGY_MAX = 100
const MOVEMENT_DRAIN_RATE = 5

const LIFE_MAX = 100

@onready var beam = $Beam
@onready var beam_collider = $Beam/CollisionShape2D
@onready var chomper_collider = $Chomper/CollisionShape2D
@onready var beam_sound = $Beam/BeamSound
@onready var energy_line: Line2D = $EnergyLine

var energy = ENERGY_MAX
var life = LIFE_MAX

func _ready():
	beam.visible = false
	beam_collider.disabled = true
	chomper_collider.disabled = true

func _physics_process(delta):
	var beaming = false
	var moving = false
	
	if Input.is_action_just_pressed("beam"):
		beam_sound.play()

	if Input.is_action_just_released("beam"):
		beam_sound.stop()


	if Input.is_action_pressed("beam") && energy > 0:
		beaming = true
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

		var direction = Input.get_axis("left", "right")
		if direction:
			moving = true
			velocity.x = direction * SPEED
			energy -= MOVEMENT_DRAIN_RATE * delta
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		var direction2 = Input.get_axis("up", "down")
		if direction2:
			moving = true
			velocity.y = direction2 * SPEED
			energy -= MOVEMENT_DRAIN_RATE * delta
		else:
			velocity.y = move_toward(velocity.y, 0, SPEED)

	if energy < 0:
		energy = 0

	if energy < ENERGY_MAX && not beaming && not moving:
		energy += ENERGY_RECHARGE_RATE * delta


	energy_line.width = 52 * energy / ENERGY_MAX

	move_and_slide()


func _on_chomper_body_entered(body):
	if body.is_in_group("Consumable"):
		body.queue_free()
