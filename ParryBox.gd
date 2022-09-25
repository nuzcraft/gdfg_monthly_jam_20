extends Area2D

onready var collisionShape := $CollisionShape2D

var is_parrying = false

func start_parry(parry_duration):
	is_parrying = true
	collisionShape.set_deferred('disabled', false)
	yield(get_tree().create_timer(parry_duration), 'timeout')
	collisionShape.set_deferred('disabled', true)                                  
	is_parrying = false

func _on_ParryBox_area_entered(area):
	area.owner.parried()
	Events.emit_signal("parried")
