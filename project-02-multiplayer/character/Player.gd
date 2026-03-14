extends CharacterBody2D

@onready var jump_sound = $JumpSound

# Exporting these allows us to set different keys for P1 and P2 in the Inspector
@export var jump_action: String = "ui_accept"
@export var duck_action: String = "ui_down"

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800
const FAST_DROP_SPEED : int = 3000 

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			# Use the dynamic jump_action instead of "ui_accept"
			if Input.is_action_pressed(jump_action):
				velocity.y = JUMP_SPEED
				jump_sound.play()
			else:
				$AnimatedSprite2D.play("running")
	else:
		$AnimatedSprite2D.play("jumping")
		
		# Use the dynamic duck_action instead of "ui_down"
		if Input.is_action_just_pressed(duck_action):
			velocity.y = FAST_DROP_SPEED

	move_and_slide()
