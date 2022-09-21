extends Node

onready var blinkTimer := $BlinkTimer
onready var durationTimer := $DurationTimer
var blink_object = Node2D

func start_blinking(object, duration):
	blink_object = object
	durationTimer.wait_time = duration
	durationTimer.start()
	blinkTimer.start()
	
func _on_BlinkTimer_timeout():
	blink_object.visible = !blink_object.visible
	
func _on_DurationTimer_timeout():
	blinkTimer.stop()
	blink_object.visible = true
