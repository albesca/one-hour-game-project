extends Area2D


signal clicked(type)
signal despawn(type)

var object_type = Color.WHITE
var lifespan = 5

# Called when the node enters the scene tree for the first time.
func _ready():
	$LifeTimer.wait_time = lifespan
	$LifeTimer.start()
	$ColorRect.color = object_type


func _on_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouse:
		print(event)
		if event is InputEventMouseButton and event.pressed:
			emit_signal("clicked", object_type)
			$LifeTimer.stop()
			queue_free()


func _on_life_timer_timeout():
	emit_signal("despawn", object_type)
	queue_free()
