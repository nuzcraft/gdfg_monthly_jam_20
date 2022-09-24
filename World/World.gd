extends Node2D

onready var player := $Player
onready var camera := $Camera2D
onready var scoreLabel := $HUD/ScoreLabel

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connectCamera(camera)
	Events.connect("parried", self, "_on_parried")
	Events.connect("enemy_died", self, "_on_enemy_died")


func _on_parried():
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "zoom", Vector2(0.75, 0.75), 0.2)
	tween.parallel().tween_property(Engine, "time_scale", 0.5, 0.2)
	tween.tween_property(camera, "zoom", Vector2(1, 1), 1.2)
	tween.parallel().tween_property(Engine, "time_scale", 1.0, 1.2)
	
func _on_enemy_died():
	score += 1
	scoreLabel.text = str(score)
