extends CharacterBody2D

const GRAVITY : int = 4200
const JUMP_SPEED : int = -1800
const FAST_DROP_SPEED : int = 3000 

func _physics_process(delta):
	velocity.y += GRAVITY * delta
	if is_on_floor():
		if not get_parent().game_running:
			$AnimatedSprite2D.play("idle")
		else:
			if Input.is_action_pressed("ui_accept"):
				velocity.y = JUMP_SPEED
			else:
				$AnimatedSprite2D.play("running")
	else:
		$AnimatedSprite2D.play("jumping")
		if Input.is_action_just_pressed("ui_down"):
			velocity.y = FAST_DROP_SPEED

	move_and_slide()
