extends Node

const HURT = preload("res://Sounds/hurt.wav")
const ENEMY_ATTACK = preload("res://Sounds/enemy_attack.wav")
const ENEMY_JUMP = preload("res://Sounds/enemy_jump.wav")
const LOSE = preload("res://Sounds/lose.wav")
const PLAYER_ATTACK = preload("res://Sounds/player_attack.wav")
const PLAYER_JUMP = preload("res://Sounds/player_jump.wav")
const PLAYER_PARRY = preload("res://Sounds/player_parry.wav")
const START = preload("res://Sounds/start.wav")
const MUSIC = preload("res://Sounds/desertbounce-trimmed.wav")

onready var audioPlayers := $AudioPlayers
onready var musicPlayers := $MusicPlayers

func play_sound(sound):	
	for audioStreamPlayer in audioPlayers.get_children():
		if not audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.play()
			break

func play_music(sound):	
	for audioStreamPlayer in musicPlayers.get_children():
		if not audioStreamPlayer.playing:
			audioStreamPlayer.stream = sound
			audioStreamPlayer.play()
			break
			
func stop_music():
	for audioStreamPlayer in musicPlayers.get_children():
		if audioStreamPlayer.playing:
			audioStreamPlayer.stop()
