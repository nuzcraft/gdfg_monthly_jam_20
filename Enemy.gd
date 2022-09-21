extends KinematicBody2D

const attack_duration = 1
const whiten_duration = 0.15

var whiten_material = preload("res://shaders/whiten_material2.tres")

onready var attackTimer := $AttackTimer
onready var warningTimer := $WarningTimer
onready var leftHitBox := $LeftHitbox


func _ready():
	attackTimer.start()
	leftHitBox.hide()

func attack():
	leftHitBox.show()
	leftHitBox.start_attack(attack_duration)
	
func whiten():
	whiten_material.set_shader_param('whiten', true)
	yield(get_tree().create_timer(whiten_duration), 'timeout')
	whiten_material.set_shader_param('whiten', false)
	
func parried():
	leftHitBox.disable()
	leftHitBox.hide()
	warningTimer.stop()
	attackTimer.stop()
	attackTimer.start()

func _on_AttackTimer_timeout():
	whiten()
	warningTimer.start()

func _on_LeftHitbox_attack_complete():
	leftHitBox.hide()
	attackTimer.start()

func _on_WarningTimer_timeout():
	attack()
