extends CharacterBody2D

@export var move_speed := 200.0
@onready var anim := $Sprite2D  # Make sure this is AnimatedSprite2D

# ================= VARIABLES =================
var is_attacking := false
var current_anim := ""  # Track current animation to prevent freezing

enum Direction { UP, DOWN, LEFT, RIGHT }
var facing := Direction.DOWN

# ================= INPUT =================
func _process(delta):
	if Input.is_action_just_pressed("mouse_left") and not is_attacking:
		attack()

# ================= PHYSICS & MOVEMENT =================
func _physics_process(delta):
	# Stop movement during attack
	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		# Fallback: if animation finished but signal misfires
		if not anim.is_playing():
			is_attacking = false
		return

	# Movement input
	var input_dir = Vector2.ZERO
	input_dir.x = Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left")
	input_dir.y = Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")

	if input_dir != Vector2.ZERO:
		input_dir = input_dir.normalized()
		velocity = input_dir * move_speed
		update_facing(input_dir)
		play_walk()
	else:
		velocity = Vector2.ZERO
		play_idle()

	move_and_slide()

# ================= DIRECTION =================
func update_facing(dir: Vector2):
	if abs(dir.x) > abs(dir.y):
		if dir.x > 0:
			facing = Direction.RIGHT
		else:
			facing = Direction.LEFT
	else:
		if dir.y > 0:
			facing = Direction.DOWN
		else:
			facing = Direction.UP

# ================= ANIMATION =================
func play_walk():
	match facing:
		Direction.UP:
			_set_anim("walk_back")
		Direction.DOWN:
			_set_anim("walk_front")
		Direction.LEFT:
			_set_anim("walk_left")
		Direction.RIGHT:
			_set_anim("walk_right")

func play_idle():
	match facing:
		Direction.UP:
			_set_anim("idle_back")
		Direction.DOWN:
			_set_anim("idle_front")
		Direction.LEFT:
			_set_anim("idle_left")
		Direction.RIGHT:
			_set_anim("idle_right")

# Only change animation when needed (prevents frame reset)
func _set_anim(name: String):
	if current_anim == name:
		return
	anim.play(name)
	current_anim = name

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP and event.pressed:
			$Camera2D.zoom *= 0.9  # zoom in
		elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN and event.pressed:
			$Camera2D.zoom *= 1.1  # zoom out
	 # Clamp so zoom doesn’t go too extreme
		$Camera2D.zoom.x = clamp($Camera2D.zoom.x, 0.7, 5)
		$Camera2D.zoom.y = clamp($Camera2D.zoom.y, 0.7, 5)


# ================= ATTACK =================
func attack():
	is_attacking = true
	match facing:
		Direction.UP:
			_set_anim("attack_back")
		Direction.DOWN:
			_set_anim("attack_front")
		Direction.LEFT:
			_set_anim("attack_left")
		Direction.RIGHT:
			_set_anim("attack_right")

# ================= SIGNAL =================
# Connect this signal from AnimatedSprite2D → Player node
func _on_Sprite2D_animation_finished(anim_name: StringName):
	if anim_name.begins_with("attack"):
		is_attacking = false
