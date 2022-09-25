extends Node2D

onready var player := $Player
onready var camera := $Camera2D
onready var scoreLabel := $HUD/ScoreLabel
onready var hud := $HUD
onready var title := $Title
onready var heart1 := $"HUD/Heart 1"
onready var heart2 := $"HUD/Heart 2"
onready var heart3 := $"HUD/Heart 3"
onready var enemy := preload("res://Enemy.tscn")
onready var spawners := get_tree().get_nodes_in_group("spawners")
onready var spawnTimer := $SpawnTimer
onready var restart := $Restart
onready var controls := $Controls

var score = 0
var rng = RandomNumberGenerator.new()
var game_started = false
var controls_shown = false
var player_dead = false
var dead_sound_played = false

# Called when the node enters the scene tree for the first time.
func _ready():
	player.connectCamera(camera)
	Events.connect("parried", self, "_on_parried")
	Events.connect("enemy_died", self, "_on_enemy_died")
	Events.connect("player_died", self, "_on_player_died")
	title.show()
	hud.hide()
	restart.hide()
	controls.hide()
	
	
func start_game():
	title.hide()
	hud.show()
	restart.hide()
	controls.hide()
	spawnTimer.start()
	spawn_enemy()
	spawn_enemy()
	spawn_enemy()
	game_started = true
	dead_sound_played = false
	SoundPlayer.play_music(SoundPlayer.MUSIC)
	
func _physics_process(delta):
	if player.health < 3:
		heart3.visible = false
	if player.health < 2:
		heart2.visible = false
	if player.health < 1:
		heart1.visible = false

func _input(event):
	if not game_started:
		if event.is_pressed() and controls_shown:
			start_game()
		if event.is_pressed() and not controls_shown:
			title.hide()
			controls.show()
			controls_shown = true
			
	if player_dead:
		if event.is_pressed():
			get_tree().reload_current_scene()


func _on_parried():
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(camera, "zoom", Vector2(0.75, 0.75), 0.2)
	tween.parallel().tween_property(Engine, "time_scale", 0.5, 0.2)
	tween.tween_property(camera, "zoom", Vector2(1, 1), 1.2)
	tween.parallel().tween_property(Engine, "time_scale", 1.0, 1.2)
	
func _on_enemy_died():
	score += 1
	scoreLabel.text = str(score)
	make_it_harder(score)

func _on_SpawnTimer_timeout():  
	spawn_enemy()
	
func spawn_enemy():
	randomize()
	var new_enemy = enemy.instance()
	var new_enemy_position = spawners[randi()%spawners.size()].global_position
	var offset = rng.randi_range(-2, 2)
	new_enemy.position = new_enemy_position + Vector2(offset, 0)
	add_child(new_enemy)
	
func make_it_harder(score):
	if score == 5:
		spawnTimer.wait_time = 8
		spawn_enemy()
		spawn_enemy()
	if score == 10:
		spawnTimer.wait_time = 5
		spawn_enemy()
		spawn_enemy()
		spawn_enemy()
	if score == 20:
		spawnTimer.wait_time = 3.5
		spawn_enemy()
		spawn_enemy()
		spawn_enemy()
	if score == 50:
		spawnTimer.wait_time = 2
		spawn_enemy()
		spawn_enemy()
		spawn_enemy()
		spawn_enemy()

func _on_player_died():
	restart.show()
	SoundPlayer.stop_music()
	if dead_sound_played == false:
		SoundPlayer.play_sound(SoundPlayer.LOSE)
		dead_sound_played = true
	yield(get_tree().create_timer(2.0), "timeout")
	player_dead = true
	
	
