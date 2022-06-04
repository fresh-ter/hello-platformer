extends AnimatedSprite

export (bool) onready var invert_direction setget set_invert_direction
export (int) onready var speed = 20
export (float) onready var lifetime = 2.5

var is_released: bool = false

var timer: float = 0


func _ready():
	pass


func _process(delta: float) -> void:
	if not is_released:
		return
	
	timer += delta
	if timer > lifetime: queue_free()
	
	if invert_direction:
		position -= Vector2(speed * 10 * delta, 0)
	else:
		position += Vector2(speed * 10 * delta, 0)


func shot():
	play("flying")
	is_released = true


func set_invert_direction(value) -> void:
	if value:
		flip_h = true
	else:
		flip_h = false
	
	invert_direction = value
