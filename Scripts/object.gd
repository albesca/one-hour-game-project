extends Area2D


signal clicked(type, object)
signal despawn(type, object)

var object_type = Color.WHITE
var object_texture = ""
var lifespan = 5

var sounds = []

var animation_done = false
var sound_done = false


func _process(_delta):
	if animation_done and sound_done:
		queue_free()


# Called when the node enters the scene tree for the first time.
func _ready():
	$LifeTimer.wait_time = lifespan
	$LifeTimer.start()
	#$ColorRect.color = object_type
	$TextureRect.texture = load(object_texture)


func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouse:
		print(event)
		if event is InputEventMouseButton and event.pressed:
			emit_signal("clicked", object_type, self)
			$CollisionShape2D.set_deferred("disabled", true)
			$LifeTimer.stop()
			#queue_free()


func _on_life_timer_timeout():
	$CollisionShape2D.set_deferred("disabled", true)
	emit_signal("despawn", object_type, self)
	#queue_free()


func _on_smiley_animation_finished():
	animation_done = true


func play_smiley(happy):
	var animation
	if happy:
		animation = "happy"
		$SoundPlayer.stream = sounds[0]
	else:
		animation = "sad"
		$SoundPlayer.stream = sounds[1]

	$AnimatedSprite2D.play(animation)
	$SoundPlayer.play()


func _on_sound_player_finished():
	sound_done = true
