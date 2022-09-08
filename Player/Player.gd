extends KinematicBody2D

export(int) var JUMP_VELOCITY = 120
export(int) var JUMP_RELEASE_VELOCITY = 60
export(int) var DOUBLE_JUMP_COUNT = 0
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
var buffered_jump = false
var coyote_jump = false

onready var animatedSprite := $AnimatedSprite
onready var jumpBufferTimer := $JumpBufferTimer
onready var coyoteJumpTimer := $CoyoteJumpTimer
onready var runningSparksLeft := $RunningSparksLeft
onready var runningSparksRight := $RunningSparksRight
onready var dustParticles := preload("res://Player/DustParticles.tscn")


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
		animatedSprite.animation = "idle"
		runningSparksLeft.emitting = false
		runningSparksRight.emitting = false
	if input.x != 0:
		apply_acceleration(input, delta)
		animatedSprite.flip_h = input.x < 0
		animatedSprite.animation = "running"
		if input.x < 0 and velocity.x < 0:
			runningSparksRight.emitting = true
			runningSparksLeft.emitting = false
		if input.x > 0 and velocity.x > 0:
			runningSparksLeft.emitting = true
			runningSparksRight.emitting	= false
		
	if is_on_floor():
		double_jump = DOUBLE_JUMP_COUNT
		
	if is_on_floor() or coyote_jump:
		if Input.is_action_just_pressed("ui_up") or buffered_jump:
			add_child(dustParticles.instance())
			velocity.y = -JUMP_VELOCITY
			buffered_jump = false
		
	if not is_on_floor():
		runningSparksLeft.emitting = false
		runningSparksRight.emitting = false
		if Input.is_action_just_released("ui_up") and velocity.y < -JUMP_RELEASE_VELOCITY:
			velocity.y = -JUMP_RELEASE_VELOCITY

		if velocity.y > 0:
			velocity.y += EXTRA_GRAVITY * delta
			animatedSprite.animation = "jump"
			animatedSprite.frame = 1
		else:
			animatedSprite.animation = "jump"
			animatedSprite.frame = 0
			
		if Input.is_action_just_pressed("ui_up") and double_jump > 0:
			velocity.y = -JUMP_VELOCITY
			double_jump -= 1
			
		if Input.is_action_just_pressed("ui_up"):
			buffered_jump = true
			jumpBufferTimer.start()
		
	var was_on_floor = is_on_floor()	
	velocity = move_and_slide(velocity, Vector2.UP)
	if was_on_floor and not is_on_floor() and velocity.y > 0:
		coyote_jump = true
		coyoteJumpTimer.start()
	
func apply_gravity(delta):
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, MAX_GRAVITY)
	
func apply_acceleration(input, delta):
	velocity.x += ACCELERATION * delta * input.x
	velocity.x *= pow(1-ACCELERATION_DAMPING, delta*10)
	
func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
		
func _on_JumpBufferTimer_timeout():
	buffered_jump = false

func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false
