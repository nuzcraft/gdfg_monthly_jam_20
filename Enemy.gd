extends KinematicBody2D

const attack_duration = 1
const whiten_duration = 0.15
enum{
	LEFT,
	RIGHT
}

export(int) var FRICTION = 400
export(int) var GRAVITY = 400
export(int) var MAX_GRAVITY = 600
export(int) var JUMP_VELOCITY = 120
export(int) var ATTACK_DISTANCE = 30
export(float) var INVINCIBILITY_DURATION = 1.5
export(int) var health = 2

#var whiten_material = preload("res://shaders/whiten_material2.tres")
var whiten_material = null
var attacking_direction = null
var can_attack = false
var is_attacking = false
var velocity = Vector2.ZERO

onready var animatedSprite := $AnimatedSprite
onready var attackTimer := $AttackTimer
onready var warningTimer := $WarningTimer
onready var leftHitBox := $LeftHitbox
onready var rightHitBox := $RightHitbox
onready var animationPlayer := $AnimationPlayer
onready var hurtbox := $Hurtbox
onready var blinker := $Blinker
onready var player = get_tree().get_root().get_node("World/Player")


func _ready():
	whiten_material = animatedSprite.get_material()
	leftHitBox.hide()
	rightHitBox.hide()
	animatedSprite.play("idle")
	attackTimer.start()
	
func _physics_process(delta):
	if global_position.distance_to(player.global_position) < ATTACK_DISTANCE and not is_attacking:
		can_attack = true
	else:
		can_attack = false
	apply_gravity(delta)
	apply_friction(delta)
	
	if velocity.x == 0 and not is_attacking:
		animatedSprite.play("idle")
	
	if health <= 0:
		die()
	
	velocity = move_and_slide(velocity, Vector2.UP)

func attack(direction):
	if direction == LEFT:
		animationPlayer.play("attack left")
		yield(get_tree().create_timer(0.1), 'timeout')
		leftHitBox.show()
		leftHitBox.start_attack(attack_duration)
		SoundPlayer.play_sound(SoundPlayer.ENEMY_ATTACK)
	if direction == RIGHT:
		animationPlayer.play("attack right")
		yield(get_tree().create_timer(0.1), 'timeout')
		rightHitBox.show()
		rightHitBox.start_attack(attack_duration)
		SoundPlayer.play_sound(SoundPlayer.ENEMY_ATTACK)
	
func whiten():
	whiten_material.set_shader_param('whiten', true)
	yield(get_tree().create_timer(whiten_duration), 'timeout')
	whiten_material.set_shader_param('whiten', false)
	
func parried():
	leftHitBox.disable()
	leftHitBox.hide()
	rightHitBox.disable()
	rightHitBox.hide()
	animatedSprite.animation = "idle"
	animatedSprite.frame = 0
	animatedSprite.playing = false
	warningTimer.stop()
	attackTimer.stop()
	is_attacking = false
	can_attack = false
	yield(get_tree().create_timer(1.2), 'timeout')
	animatedSprite.play("idle")
	attackTimer.start()

func _on_AttackTimer_timeout():
	if can_attack:
		start_attack()
		is_attacking = true
	elif position.distance_to(player.position) < 60:
		if get_direction_to_player() == LEFT:
			velocity.x = -JUMP_VELOCITY
		else:
			velocity.x = JUMP_VELOCITY
		velocity.y = -JUMP_VELOCITY/2
		animatedSprite.play("jump")
		SoundPlayer.play_sound(SoundPlayer.ENEMY_JUMP)
	
func start_attack():
	get_attacking_direction()
	if attacking_direction == LEFT:
		animatedSprite.animation = "attack left"
	if attacking_direction == RIGHT:
		animatedSprite.animation = "attack right"
	animatedSprite.frame = 0
	animatedSprite.playing = false
	whiten()
	warningTimer.start()
	SoundPlayer.play_sound(SoundPlayer.ENEMY_ATTACK)

func _on_LeftHitbox_attack_complete():
	leftHitBox.hide()
	attackTimer.start()
	animatedSprite.play("idle")
	is_attacking = false

func _on_WarningTimer_timeout():
	attack(attacking_direction)

func _on_RightHitbox_attack_complete():
	rightHitBox.hide()
	attackTimer.start()
	animatedSprite.play("idle")
	is_attacking = false

func get_direction_to_player():
	var direction = global_position - player.global_position
	if direction.x < 0:
		return RIGHT
	else:
		return LEFT

func get_attacking_direction():
	attacking_direction = get_direction_to_player()
	
func apply_gravity(delta):
	velocity.y += GRAVITY * delta
	velocity.y = min(velocity.y, MAX_GRAVITY)
	
	
func apply_friction(delta):
	velocity.x = move_toward(velocity.x, 0, FRICTION * delta)
	
func knockback(x_direction):
	velocity.y = -JUMP_VELOCITY / 1.5
	velocity.x = JUMP_VELOCITY / 1.5 * sign(x_direction)
	
func _on_Hurtbox_area_entered(area):
	if not hurtbox.is_invincible:
		var knockback_direction = global_position - area.global_position
		knockback(knockback_direction.x)
		blinker.start_blinking(self, INVINCIBILITY_DURATION)
		hurtbox.start_invincibility(INVINCIBILITY_DURATION)
		health -= 1
		SoundPlayer.play_sound(SoundPlayer.HURT)
		
func die():
	if not hurtbox.is_invincible:
		Events.emit_signal("enemy_died")
		queue_free()
