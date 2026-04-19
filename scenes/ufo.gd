class_name UFO

extends CharacterBody2D

signal health_depleted

const SPEED: float = 150.0
const ENERGY_DRAIN_RATE: float = 20.0
const ENERGY_RECHARGE_RATE: float = 20.0
const ENERGY_MAX: float = 100.0
const MOVEMENT_DRAIN_RATE: float = 5.0

const LIFE_MAX: float = 100.0
const LIFE_DRAIN_RATE: float = 10.0

@onready var beam: Area2D = $Beam
@onready var beam_collider: CollisionShape2D = $Beam/CollisionShape2D
@onready var chomper_collider: CollisionShape2D = $Chomper/CollisionShape2D
@onready var beam_sound: AudioStreamPlayer2D = $Beam/BeamSound
@onready var energy_line: Line2D = $EnergyLine
@onready var life_line: Line2D = $LifeLine
@onready var chomp_sound: AudioStreamPlayer2D = $Chomper/ChompSound
@onready var too_close: RayCast2D = $TooClose
@onready var close_enough: RayCast2D = $CloseEnough
@onready var close_left_light: PointLight2D = $CloseLeftLight
@onready var close_right_light: PointLight2D = $CloseRightLight
@onready var far_left_light: PointLight2D = $FarLeftLight
@onready var far_right_light: PointLight2D = $FarRightLight
@onready var nope_sound: AudioStreamPlayer2D = $NopeSound

@export var mothership: Mothership

var energy: float = ENERGY_MAX
var life: float = LIFE_MAX

func _ready():
	beam.visible = false
	beam_collider.disabled = true
	chomper_collider.disabled = true

	close_left_light.visible = false
	close_right_light.visible = false
	far_left_light.visible = false
	far_right_light.visible = false

func _physics_process(delta):
	var beaming: bool = false
	var moving: bool = false
		
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
		var direction: float = Input.get_axis("left", "right")
		
		if direction:
			moving = true
			velocity.x = direction * SPEED
			energy -= MOVEMENT_DRAIN_RATE * delta
		else:
			velocity.x = move_toward(velocity.x, 0, SPEED)
			
		var direction2: float = Input.get_axis("up", "down")
		
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
