extends Particles2D

func setup(should_spurt_right = true):
	if !should_spurt_right:
		position *= -1
		process_material.direction.x *= -1
	
	emitting = true

func _process(delta):
	if !emitting:
		queue_free()
