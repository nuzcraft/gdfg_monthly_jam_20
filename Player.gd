extends KinematicBody2D

export(int) var JUMP_VELOCITY = 120
export(int) var JUMP_RELEASE_VELOCITY = 60
export(int) var DOUBLE_JUMP_COUNT = 1
export(int) var ACCELERATION = 150
export(float) var ACCELERATION_DAMPING = 0.12
export(int) var FRICTION = 400
export(int) var GRAVITY = 400
export(int) var EXTRA_GRAVITY = 150
export(int) var MAX_GRAVITY = 600

enum {
	MOVE
}

var velocity = Vector2.ZERO
var state = MOVE
var double_jump = DOUBLE_JUMP_COUNT

onready var animatedSprite := $AnimatedSprite


func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE: move_state(input, delta)
	
func move_state(input, delta):
	apply_gravity(delta)
	
	if input.x == 0:
		apply_friction(delta)
	if input.x != 0:
		apply_acceleration(input, delta)
		animatedSprite.flip_h = input.x < 0
		
	if is_on_floor():
		double_jump = DOUBLE_JUMP_COUNT
		
	if Input.is_action_just_pressed("ui_up") and is_on_floor():
		velocity.y = -JUMP_VELOCITY
		
	if not is_on_floor():
		if Input.is_action_just_released("ui_up") and velocity.y < -JUMP_RELEASE_VELOCITY:
			velocity.y = -JUMP_RELEASE_VELOCITY

		if velocity.y > 0:
			velocity.y += EXTRA_GRAVITY * delta
			
		if Input.is_action_just_pressed("ui_up") and double_jump > 0:
			velocity.y = -JUMP_VELOCITY
			double_jump -= 1
		
	velocity = move_and_slide(velocity, Vector2.UP)
	
func apply_gravity(delta):
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, MAX_GRAVITY)
	
func apply_acceleration(input, delta):
	velocity.x += ACCELERATION * delta * input.x
	velocity.x *= pow(1-ACCELERATION_DAMPING, delta*10)
	
func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		
