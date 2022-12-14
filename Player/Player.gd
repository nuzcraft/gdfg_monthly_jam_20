extends KinematicBody2D
class_name Player

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
export(float) var COUNTERATTACK_VELOCITY = 150
export(int) var MAX_HEALTH = 3

enum {
	MOVE,
	PARRY,
}

var velocity = Vector2.ZERO
var state = MOVE
var double_jump = DOUBLE_JUMP_COUNT
var buffered_jump = false
var coyote_jump = false
var counterattack = 1
var health = MAX_HEALTH

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
onready var animationPlayer := $AnimationPlayer
onready var parryFlash := $ParryFlash
onready var hitbox := $Hitbox

func _ready():
	Events.connect("parried", self, "_on_parried")
	animatedSprite.play("idle")
	parryFlash.hide()

func _physics_process(delta):
	var input = Vector2.ZERO
	input.x = Input.get_axis("ui_left", "ui_right")
	input.y = Input.get_axis("ui_up", "ui_down")
	
	if health <= 0:
		die()
	
	match state:
		MOVE: move_state(input, delta)
		PARRY: parry_state(input, delta)
	
func move_state(input, delta):
	apply_gravity(delta)
	
	if input.x == 0:
		apply_friction(delta)
		runningSparksLeft.emitting = false
		runningSparksRight.emitting = false
		if is_on_floor() and not is_parrying():
			animatedSprite.animation = "idle"
			animatedSprite.playing = true
	if input.x != 0:
		apply_acceleration(input, delta)
		animatedSprite.flip_h = input.x < 0
		if is_on_floor() and not is_parrying():
			animatedSprite.animation = "running"
			animatedSprite.playing = true
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
			SoundPlayer.play_sound(SoundPlayer.PLAYER_JUMP)
		
	if not is_on_floor():
		runningSparksLeft.emitting = false
		runningSparksRight.emitting = false
		if Input.is_action_just_released("ui_up") and velocity.y < -JUMP_RELEASE_VELOCITY:
			velocity.y = -JUMP_RELEASE_VELOCITY

		if velocity.y > 0:
			velocity.y += EXTRA_GRAVITY * delta
			if double_jump >= DOUBLE_JUMP_COUNT and not is_parrying():
				animatedSprite.animation = "jump"
				animatedSprite.frame = 1
				animatedSprite.playing = false
		else:
			if double_jump >= DOUBLE_JUMP_COUNT and not is_parrying():
				animatedSprite.animation = "jump"
				animatedSprite.frame = 0
				animatedSprite.playing = false
			
		if Input.is_action_just_pressed("ui_up") and double_jump > 0:
			velocity.y = -JUMP_VELOCITY
			double_jump -= 1
			SoundPlayer.play_sound(SoundPlayer.PLAYER_JUMP)
			if not is_parrying():
				animatedSprite.animation = "double jump"
				animatedSprite.playing = true
			
		if Input.is_action_just_pressed("ui_up"):
			buffered_jump = true
			jumpBufferTimer.start()
			
	check_for_parry()
		
	var was_on_floor = is_on_floor()	
	velocity = move_and_slide(velocity, Vector2.UP)
	if was_on_floor and not is_on_floor() and velocity.y > 0:
		coyote_jump = true
		coyoteJumpTimer.start()

func parry_state(input, delta):
	apply_gravity(delta)
	apply_friction(delta)
	if Input.is_action_just_pressed("parry") and counterattack > 0:
		input = input.normalized()
		if input.x:
			velocity.x = sign(input.x) * COUNTERATTACK_VELOCITY
		if input.y:
			velocity.y = sign(input.y) * COUNTERATTACK_VELOCITY
		counterattack -= 1
		if sign(input.x) == 1:
			animatedSprite.flip_h = false
		if sign(input.x) == -1:
			animatedSprite.flip_h = true
		animatedSprite.animation = 'running'
		animatedSprite.frame = 3
		animatedSprite.playing = false
		SoundPlayer.play_sound(SoundPlayer.PLAYER_ATTACK)
		hitbox.start_attack(1.2)
	velocity = move_and_slide(velocity, Vector2.UP)

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
		animatedSprite.animation = "parry"
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
		health -= 1
		SoundPlayer.play_sound(SoundPlayer.HURT)
		
func connectCamera(camera):
	var camera_path = camera.get_path()
	remoteTransform2D.remote_path = camera_path

func _on_ParryTimer_timeout():
	state = MOVE
	counterattack = 1
	
func _on_parried():
	state = PARRY
	parryTimer.start()
	if animatedSprite.flip_h:
		parryFlash.position.x = -6
	else:
		parryFlash.position.x = 6
	animationPlayer.play("parry flash")
	SoundPlayer.play_sound(SoundPlayer.PLAYER_PARRY)
	
func is_parrying():
	return leftParryBox.is_parrying or rightParryBox.is_parrying
	
func die():
	if not hurtbox.is_invincible:
		Events.emit_signal("player_died")
