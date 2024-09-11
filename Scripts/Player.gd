extends CharacterBody2D

var speed = 250
var face
var player_state

func _physics_process(delta):
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
	if direction.x == 0 and direction.y == 0:
		player_state = "idle"
	elif direction.x != 0.0 or direction.y != 0:
		player_state = "running"
		
	velocity = direction * speed
	move_and_slide()
	check_face()
	play_animation(direction,face)
	
func check_face():
	var direction = Input.get_vector("move_left","move_right","move_up","move_down")
	
	if direction.x > 0:
		face = "right"
	if direction.x < 0:
		face = "left"
	return face
	
func play_animation(dir,face):
	if player_state == "idle":
		if face == "right":
			$AnimationPlayer.play("idle_right")
			
		if face == "left":
			$AnimationPlayer.play("idle_left")
			
		if Input.is_action_pressed("attack"):
			$AnimationPlayer.play("AttackNoMovement")
			$AnimationPlayer.play("idle")
	
	if player_state == "running":
		if dir.x == 1:
			$AnimationPlayer.play("run")
		
		if dir.x == -1:
			$AnimationPlayer.play("run_left")
			
		if Input.is_action_pressed("attack"):
			if Input.is_action_just_released("attack") and Input.is_action_pressed("attack"):
				$AnimationPlayer.play("AttackCombo2hit")
			else:
				$AnimationPlayer.play("Attack_1")
			
		
		#play run animation in y direction
		if dir.y != 0:
			if face == "right":
				$AnimationPlayer.play("run_right")
			if face == "left":
				$AnimationPlayer.play("run_left")
