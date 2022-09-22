extends KinematicBody2D

const attack_duration = 1
const whiten_duration = 0.15
enum{
	LEFT,
	RIGHT
}

var whiten_material = preload("res://shaders/whiten_material2.tres")
var attacking_direction = null
var can_attack = false
var is_attacking = false

onready var animatedSprite := $AnimatedSprite
onready var attackTimer := $AttackTimer
onready var warningTimer := $WarningTimer
onready var leftHitBox := $LeftHitbox
onready var rightHitBox := $RightHitbox
onready var animationPlayer := $AnimationPlayer
onready var player = get_tree().get_root().get_node("World/Player")

func _ready():
	leftHitBox.hide()
	rightHitBox.hide()
	animatedSprite.play("idle")
	attackTimer.start()
	
func _physics_process(delta):
	if global_position.distance_to(player.global_position) < 50 and not is_attacking:
		can_attack = true
	else:
		can_attack = false

func attack(direction):
	if direction == LEFT:
		animationPlayer.play("attack left")
		yield(get_tree().create_timer(0.1), 'timeout')
		leftHitBox.show()
		leftHitBox.start_attack(attack_duration)
	if direction == RIGHT:
		animationPlayer.play("attack right")
		yield(get_tree().create_timer(0.1), 'timeout')
		rightHitBox.show()
		rightHitBox.start_attack(attack_duration)
	
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
	
