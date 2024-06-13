extends CharacterBody2D

var speed = 100

var player_state

func _physics_process(delta):
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
	if direction.x == 0 and direction.y == 0:
		player_state = "idle"
	elif direction.x != 0.0 or direction.y != 0:
		player_state = "running"
		
	velocity = direction * speed
	move_and_slide()

	play_animation(direction)
	
func play_animation(dir):
	if player_state == "idle":
		$AnimationPlayer.play("idle")
	
	if player_state == "running":
		if dir.x == 1:
			$AnimationPlayer.play("run_right")
		if dir.x == -1:
			$AnimationPlayer.play("run_left")
