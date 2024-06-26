extends Node2D


@export var object_scene : PackedScene
@export var max_lives = 3

var object_types = {
	"red": "res://Images/red_apple.png",
	"blue": "res://Images/purple_eggplant.png",
	"green": "res://Images/yellow_lemon.png"
}

var normal_sounds_ok = [
	"res://Sounds/ok_n_01.wav",
	"res://Sounds/ok_n_02.wav",
	"res://Sounds/ok_n_03.wav",
	"res://Sounds/ok_n_04.wav"
]

var normal_sounds_ko = [
	"res://Sounds/ko_n_01.wav",
	"res://Sounds/ko_n_02.wav",
	"res://Sounds/ko_n_03.wav",
	"res://Sounds/ko_n_04.wav"
]

var special_sounds_ok = [
	"res://Sounds/ok_s_01.wav",
	"res://Sounds/ok_s_02.wav"
]

var special_sounds_ko = [
	"res://Sounds/ko_s_01.wav",
	"res://Sounds/ko_s_02.wav"
]

var max_spawn_rate = 5
var max_lifespan = 9.5

var object_counter
var lifespan
var spawn_rate
var lives
var score

var game_going = false

var target

var rng


func _ready():
	$MusicPlayer.play()
	rng = RandomNumberGenerator.new()
	rng.randomize()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if game_going:
		$Lives.text = "lives: %d" % lives
		$Score.text = "score: %d" % score
		if lives <= 0:
			game_going = false
			$SpawnTimer.stop()
			$GameEndMessage.visible = true
			$GameEndMessage.text = "You lost - final score: %d" % score
			$Restart.visible = true
		elif spawn_rate == 0:
			game_going = false
			$SpawnTimer.stop()
			$GameEndMessage.visible = true
			$GameEndMessage.text = "You win - final score: %d" % score
			$Restart.visible = true
		
		if object_counter == 10:
			object_counter = 0
			spawn_rate -= 1
			lifespan -= 2
			if spawn_rate > 0:
				$SpawnTimer.wait_time = spawn_rate
	else:
		$Lives.text = "lives: -"
		$Score.text = "score: -"



func _on_start_pressed():
	reset()
	$Start.visible = false


func _on_restart_pressed():
	reset()
	$Restart.visible = false


func reset():
	lifespan = max_lifespan
	spawn_rate = max_spawn_rate
	score = 0
	lives = max_lives
	object_counter = 0
	game_going = true
	$SpawnTimer.wait_time = max_spawn_rate
	$SpawnTimer.start()
	$GameEndMessage.visible = false
	target = object_types.keys()[rng.randi_range(0, len(object_types.keys()) - 1)]
	#$TargetColor.color = object_types[target]
	$TargetTexture.texture = load(object_types[target])


func _on_spawn_timer_timeout():
	var object = object_scene.instantiate()
	object.position = Vector2(rng.randi_range(30, 450), rng.randi_range(80, 450))
	var object_key = object_types.keys()[rng.randi_range(0, len(object_types.keys()) - 1)]
	object.object_type = object_key
	object.object_texture = object_types[object_key]
	object.lifespan = lifespan
	add_child(object)
	object_counter += 1
	object.connect("clicked", click_object)
	object.connect("despawn", despawn_object)
	var audio_ok
	var audio_ko
	if rng.randi_range(1, 10) == 1:
		audio_ok = load(special_sounds_ok[rng.randi_range(0, len(special_sounds_ok) - 1)])
		audio_ko = load(special_sounds_ko[rng.randi_range(0, len(special_sounds_ko) - 1)])
	else:
		audio_ok = load(normal_sounds_ok[rng.randi_range(0, len(normal_sounds_ok) - 1)])
		audio_ko = load(normal_sounds_ko[rng.randi_range(0, len(normal_sounds_ko) - 1)])
	
	object.sounds.append(audio_ok)
	object.sounds.append(audio_ko)

	if rng.randi_range(1, 5) == 1:
		target = object_types.keys()[rng.randi_range(0, len(object_types.keys()) - 1)]
		#$TargetColor.color = object_types[target]
		$TargetTexture.texture = load(object_types[target])


func despawn_object(type, object):
	var happy
	if type == target:
		lives -= 1
		happy = false
	else:
		score += 1
		happy = true
	
	object.play_smiley(happy)


func click_object(type, object):
	var happy
	if type == target:
		score += 1
		happy = true
	else:
		lives -= 1
		happy = false
	
	object.play_smiley(happy)


func _on_sound_button_toggled(button_pressed):
	AudioServer.set_bus_mute(0, button_pressed)
