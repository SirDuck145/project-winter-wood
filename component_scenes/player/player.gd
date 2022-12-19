extends KinematicBody2D

var movespeed = 100

func _physics_process(delta):
	handle_movement(delta)

func handle_movement(delta):
	var direction = Vector2(0, 0)
	
	if Input.is_action_pressed("down"):
		direction.y += 1
	if Input.is_action_pressed("up"):
		direction.y -= 1
	if Input.is_action_pressed("right"):
		direction.x += 1
	if Input.is_action_pressed("left"):
		direction.x -= 1

	direction = direction.normalized()
	
	move_and_collide(direction * movespeed * delta)
