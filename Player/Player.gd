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
export(float) var INVINCIBILITY_DURATION = 1
export(float) var PARRY_DURATION = 0.5

enum {
	MOVE,
	PARRY,
}

var velocity = Vector2.ZERO
var state = MOVE
var double_jump = DOUBLE_JUMP_COUNT
var buffered_jump = false
var coyote_jump = false

onready var animatedSprite := $AnimatedSprite
onready var leftParryBox := $LeftParryBox
onready var rightParryBox := $RightParryBox
onready var jumpBufferTimer := $JumpBufferTimer
onready var coyoteJumpTimer := $CoyoteJumpTimer
onready var parryTimer := $ParryTimer
onready var runningSparksLeft := $RunningSparksLeft
onready var runningSparksRight := $RunningSparksRight
onready var hurtbox := $Hurtbox
onready var blinker := $Blinker
onready var dustParticles := preload("res://Player/DustParticles.tscn")
onready var remoteTransform2D := $RemoteTransform2D

func _ready():
	Events.connect("parried", self, "_on_parried")

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	match state:
		MOVE: move_state(input, delta)
		PARRY: parry_state()
	
func move_state(input, delta):
	apply_gravity(delta)
	
	if input.x == 0:
		apply_friction(delta)
		runningSparksLeft.emitting = false
		runningSparksRight.emitting = false
		if is_on_floor():
			animatedSprite.animation = "idle"
	if input.x != 0:
		apply_acceleration(input, delta)
		animatedSprite.flip_h = input.x < 0
		if is_on_floor():
			animatedSprite.animation = "running"
		if input.x < 0 and velocity.x < 0:
			runningSparksRight.emitting = true
			runningSparksLeft.emitting = false
		if input.x > 0 and velocity.x > 0:
			runningSparksLeft.emitting = true
			runningSparksRight.emitting	= false
			
	check_for_parry()
		
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
			if double_jump >= DOUBLE_JUMP_COUNT:
				animatedSprite.animation = "jump"
				animatedSprite.frame = 1
		else:
			if double_jump >= DOUBLE_JUMP_COUNT:
				animatedSprite.animation = "jump"
				animatedSprite.frame = 0
			
		if Input.is_action_just_pressed("ui_up") and double_jump > 0:
			velocity.y = -JUMP_VELOCITY
			double_jump -= 1
			animatedSprite.animation = "double jump"
			
		if Input.is_action_just_pressed("ui_up"):
			buffered_jump = true
			jumpBufferTimer.start()
		
	var was_on_floor = is_on_floor()	
	velocity = move_and_slide(velocity, Vector2.UP)
	if was_on_floor and not is_on_floor() and velocity.y > 0:
		coyote_jump = true
		coyoteJumpTimer.start()

func parry_state():
	pass

func apply_gravity(delta):
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, MAX_GRAVITY)
	
func apply_acceleration(input, delta):
	velocity.x += ACCELERATION * delta * input.x
	velocity.x *= pow(1-ACCELERATION_DAMPING, delta*10)
	
func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
func knockback(x_direction):
	velocity.y = -JUMP_VELOCITY / 1.5
	velocity.x = JUMP_VELOCITY / 1.5 * sign(x_direction)
	
func check_for_parry():
	if Input.is_action_just_pressed("parry"):
		hurtbox.start_invincibility(PARRY_DURATION)
		if not animatedSprite.flip_h:
			leftParryBox.start_parry(PARRY_DURATION)
		if animatedSprite.flip_h:
			rightParryBox.start_parry(PARRY_DURATION)
		
func _on_JumpBufferTimer_timeout():
	buffered_jump = false

func _on_CoyoteJumpTimer_timeout():
	coyote_jump = false

func _on_Hurtbox_area_entered(area):
	if not hurtbox.is_invincible:
		var knockback_direction = global_position - area.global_position
		knockback(knockback_direction.x)
		blinker.start_blinking(self, INVINCIBILITY_DURATION)
		hurtbox.start_invincibility(INVINCIBILITY_DURATION)
		print("ouchy")
		
func connectCamera(camera):
	var camera_path = camera.get_path()
	remoteTransform2D.remote_path = camera_path

func _on_ParryTimer_timeout():
	state = MOVE
	
func _on_parried():
	state = PARRY
	parryTimer.start()
