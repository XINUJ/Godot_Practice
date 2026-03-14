extends Area2D

var run_speed = 1.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x -= run_speed
	var camera_x = get_parent().get_node("Camera2D").position.x
	if position.x < (camera_x - 700): 
		get_parent().remove_obs(self)
