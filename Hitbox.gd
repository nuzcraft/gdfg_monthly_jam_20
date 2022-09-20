extends Area2D

signal attack_complete

onready var collisionShape := $CollisionShape2D


var is_attacking = false

func start_attack(attack_duration):
	is_attacking = true
	collisionShape.set_deferred('disabled', false)
	yield(get_tree().create_timer(attack_duration), 'timeout')
	collisionShape.set_deferred('disabled', true)
	is_attacking = false
	emit_signal("attack_complete")
	
