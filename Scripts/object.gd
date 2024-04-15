extends Area2D


signal clicked(type, object)
signal despawn(type, object)

var object_type = Color.WHITE
var object_texture = ""
var lifespan = 5

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
	queue_free()


func play_smiley(happy):
	if happy:
		$AnimatedSprite2D.play("happy")
	else:
		$AnimatedSprite2D.play("sad")
