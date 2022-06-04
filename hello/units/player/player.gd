extends KinematicBody2D

const gravityPower = 10
const jumpPower = 21
const movementSpeed = 10

var gravity = 0
var velocity = Vector2(0, 0)
var movementVelocity = Vector2(0, 0)

onready var sprite = $AnimatedSprite
onready var shotSprite = $Shot


var doubleJump = true
var tripleJump = true
var initialPosition
var spawn = true
var protection = true
var shotInitialPosition

export (bool) var invert_direction = false setget set_invert_direction
export (bool) var is_armed: bool = false

onready var Bullet = preload("res://objects/bullet/bullet.tscn")

signal finish


func _ready():
	initialPosition = position
	shotInitialPosition = shotSprite.position

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
		self.invert_direction = true
		movementVelocity.x = -movementSpeed
		
	elif Input.is_action_pressed("right"):
		self.invert_direction = false
		movementVelocity.x = movementSpeed
	
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
	
	if Input.is_action_just_pressed("shoot") and is_armed:
		_shoot()


func _shoot() -> void:
	shotSprite.frame = 0
	shotSprite.play("shot")
	
	var bullet = Bullet.instance()
	get_tree().get_root().add_child(bullet)
	
	if self.invert_direction:
		bullet.position = position + Vector2(-8, 2)
	else:
		bullet.position = position + Vector2(8, 2)
		
	bullet.invert_direction = self.invert_direction
	bullet.shot()


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
			if is_armed:
				sprite.play("run_g")
			else:
				sprite.play("run_e")
		else:
			if is_armed:
				sprite.play("idle_g")
			else:
				sprite.play("idle_e")
	else:
		if is_armed:
			sprite.play("jump_g")
		else:
			sprite.play("jump_e")


func set_invert_direction(value) -> void:
	if value:
		sprite.flip_h = true
		shotSprite.flip_h = true
		shotSprite.position = shotInitialPosition * Vector2(-1,1)
	else:
		sprite.flip_h = false
		shotSprite.flip_h = false
		shotSprite.position = shotInitialPosition
	
	invert_direction = value


func _on_Area2D_body_entered(body: Node) -> void:
	print("npc: ", body in get_tree().get_nodes_in_group('npc'))
	print("end: ", body in get_tree().get_nodes_in_group('end'))
	
	if body in get_tree().get_nodes_in_group('npc') and not protection:
		reset()
	elif body in get_tree().get_nodes_in_group('end'):
		protection = true
		emit_signal("finish")
