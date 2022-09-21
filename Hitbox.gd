extends Area2D

signal attack_complete

onready var collisionShape := $CollisionShape2D
onready var durationTimer := $DurationTimer

var is_attacking = false

func start_attack(attack_duration):
	is_attacking = true
	collisionShape.set_deferred('disabled', false)
	durationTimer.wait_time = attack_duration
	durationTimer.start()
	
func disable():
	collisionShape.set_deferred('disabled', true)
	durationTimer.stop()
	is_attacking = false

func _on_DurationTimer_timeout():
	collisionShape.set_deferred('disabled', true)
	is_attacking = false
	emit_signal("attack_complete")
