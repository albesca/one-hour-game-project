extends Node2D


@export var object_scene : PackedScene
@export var max_lives = 3

var object_types = {
	"red": Color.RED,
	"blue": Color.BLUE,
	"green": Color.GREEN
}

var max_spawn_rate = 5
var max_lifespan = 10

var object_counter
var lifespan
var spawn_rate
var lives
var score

var game_going = false

var target

var rng


func _ready():
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
			$GameEndMessage.text = "You lost"
			$Restart.visible = true
		elif spawn_rate == 0:
			game_going = false
			$SpawnTimer.stop()
			$GameEndMessage.visible = true
			$GameEndMessage.text = "You win"
			$Restart.visible = true
		
		if object_counter == 10:
			object_counter = 0
			spawn_rate -= 1
			lifespan -= 2
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
	$TargetColor.color = object_types[target]


func _on_spawn_timer_timeout():
	var object = object_scene.instantiate()
	object.position = Vector2(rng.randi_range(30, 450), rng.randi_range(80, 450))
	object.object_type = object_types.keys()[rng.randi_range(0, len(object_types.keys()) - 1)]
	object.lifespan = lifespan
	add_child(object)
	object_counter += 1
	object.connect("clicked", click_object)
	object.connect("despawn", despawn_object)
	if rng.randi_range(1, 5) == 1:
		target = object_types.keys()[rng.randi_range(0, len(object_types.keys()) - 1)]
		$TargetColor.color = object_types[target]


func despawn_object(type):
	if type == target:
		lives -= 1
	else:
		score += 1


func click_object(type):
	if type == target:
		score += 1
	else:
		lives -= 1
