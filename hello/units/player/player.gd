extends KinematicBody2D

const gravityPower = 10
const jumpPower = 21
const movementSpeed = 10

var gravity = 0
var velocity = Vector2(0, 0)
var movementVelocity = Vector2(0, 0)

onready var sprite = $AnimatedSprite

var right_direction = true
var doubleJump = true
var tripleJump = true
var initialPosition
var spawn = true
var protection = true

signal finish


func _ready():
	initialPosition = position

func reset():
	position = initialPosition


func _physics_process(delta: float) -> void:
	if spawn and is_on_floor():
		initialPosition = position
		spawn = false
	
	if not spawn:
		_applyControls()
	_applyGravity()
	_applyAnimation()
	
	if position.y > 600:
		reset()
#
#	if is_on_wall():
#		_jump()
	
	velocity = velocity.linear_interpolate(movementVelocity * 10, delta * 15)
	move_and_slide(velocity + Vector2(0, gravity), Vector2(0, -1))
	
	sprite.scale = sprite.scale.linear_interpolate(Vector2(1, 1), delta * 8)


func _applyControls():
	movementVelocity = Vector2(0, 0)
	
	if Input.is_action_pressed("left"):
		movementVelocity.x = -movementSpeed
		sprite.flip_h = true
		
	elif Input.is_action_pressed("right"):
		movementVelocity.x = movementSpeed
		sprite.flip_h = false
	
	if Input.is_action_just_pressed("jump"):
		if is_on_floor():
			_jump()
			doubleJump = true
			
		elif doubleJump:
			_jump()
			doubleJump = false
			tripleJump = true
		
		elif tripleJump:
			_jump()
			tripleJump = false


func _jump() -> void:
	gravity = -jumpPower  * 10
	sprite.scale = Vector2(0.5, 1.5)

func _applyGravity() -> void:
	gravity += gravityPower
	
	if gravity > 0 and is_on_floor():
		gravity = 10

func _applyAnimation():
	if is_on_floor():
		if abs(velocity.x) > 2:
			sprite.play("run_e")
		else:
			sprite.play("idle_e")
	else:
		sprite.play("jump_e")

func _on_Area2D_body_entered(body: Node) -> void:
	print("npc: ", body in get_tree().get_nodes_in_group('npc'))
	print("end: ", body in get_tree().get_nodes_in_group('end'))
	
	if body in get_tree().get_nodes_in_group('npc') and not protection:
		reset()
	elif body in get_tree().get_nodes_in_group('end'):
		protection = true
		emit_signal("finish")
