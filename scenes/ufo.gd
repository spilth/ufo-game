class_name UFO
extends CharacterBody2D

signal health_depleted

const SPEED = 150.0
const ENERGY_DRAIN_RATE = 20
const ENERGY_RECHARGE_RATE = 20
const ENERGY_MAX = 100
const MOVEMENT_DRAIN_RATE = 5

const LIFE_MAX = 100
const LIFE_DRAIN_RATE = 10

@onready var beam = $Beam
@onready var beam_collider = $Beam/CollisionShape2D
@onready var chomper_collider = $Chomper/CollisionShape2D
@onready var beam_sound = $Beam/BeamSound
@onready var energy_line: Line2D = $EnergyLine
@onready var life_line: Line2D = $LifeLine
@onready var chomp_sound: AudioStreamPlayer2D = $Chomper/ChompSound
@onready var too_close = $TooClose
@onready var close_enough = $CloseEnough
@onready var close_left_light = $CloseLeftLight
@onready var close_right_light = $CloseRightLight
@onready var far_left_light = $FarLeftLight
@onready var far_right_light = $FarRightLight
@onready var nope_sound = $NopeSound

@export var mothership: Mothership

var energy = ENERGY_MAX
var life = LIFE_MAX

func _ready():
	beam.visible = false
	beam_collider.disabled = true
	chomper_collider.disabled = true

	close_left_light.visible = false
	close_right_light.visible = false
	far_left_light.visible = false
	far_right_light.visible = false

func _physics_process(delta):
	var beaming = false
	var moving = false
		
	if not too_close.is_colliding() && close_enough.is_colliding():
		close_left_light.visible = false
		close_right_light.visible = false
		far_left_light.visible = false
		far_right_light.visible = false

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
	else:
		if Input.is_action_just_pressed("beam"):
			nope_sound.play()
			
		if too_close.is_colliding():
			close_left_light.visible = true
			close_right_light.visible = true
		
		if not close_enough.is_colliding():
			far_left_light.visible = true
			far_right_light.visible = true

	if not beaming:
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

	if not beaming && not moving:
		add_energy(ENERGY_RECHARGE_RATE * delta)

	energy_line.width = 64.0  * energy / ENERGY_MAX
	life_line.width = 64.0 * life / LIFE_MAX

	move_and_slide()
	
func take_damage(amount: float):
	life -= amount
	if life <= 0:
		health_depleted.emit()

func add_energy(amount: float):
	energy += amount
	if energy > ENERGY_MAX:
		energy = ENERGY_MAX
		
func add_life(amount: float):
	life += amount
	if life > LIFE_MAX:
		life = LIFE_MAX

func _on_chomper_body_entered(body):
	if body.is_in_group("Consumable"):
		body.queue_free()
		chomp_sound.play()
		add_life(20)
		mothership.consume_human()
