extends KinematicBody2D

const attack_duration = 1
const whiten_duration = 0.15
enum{
	LEFT,
	RIGHT
}

var whiten_material = preload("res://shaders/whiten_material2.tres")
var attacking_direction = null

onready var animatedSprite := $AnimatedSprite
onready var attackTimer := $AttackTimer
onready var warningTimer := $WarningTimer
onready var leftHitBox := $LeftHitbox
onready var rightHitBox := $RightHitbox
onready var player = get_tree().get_root().get_node("World/Player")

func _ready():
	attackTimer.start()
	leftHitBox.hide()
	rightHitBox.hide()
	animatedSprite.play("idle")
	
func _physics_process(delta):
	pass

func attack(direction):
	if direction == LEFT:
		leftHitBox.show()
		leftHitBox.start_attack(attack_duration)
	if direction == RIGHT:
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
	warningTimer.stop()
	attackTimer.stop()
	attackTimer.start()

func _on_AttackTimer_timeout():
	whiten()
	warningTimer.start()
	get_attacking_direction()

func _on_LeftHitbox_attack_complete():
	leftHitBox.hide()
	attackTimer.start()

func _on_WarningTimer_timeout():
	attack(attacking_direction)

func _on_RightHitbox_attack_complete():
	rightHitBox.hide()
	attackTimer.start()

func get_direction_to_player():
	var direction = global_position - player.global_position
	if direction.x < 0:
		return RIGHT
	else:
		return LEFT

func get_attacking_direction():
	attacking_direction = get_direction_to_player()
