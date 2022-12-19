extends Control

const blood_particle_scene = preload("res://component_scenes/particles/blood_particles.tscn")

var max_health = 20
var health = max_health

onready var tween = $Tween
onready var health_bar = $HealthBar

signal player_died

func take_damage(damage):
	print("Took damage", damage)
	var new_health = health - damage
	health -= damage
	
	var blood_particle = blood_particle_scene.instance()
	get_tree().root.add_child(blood_particle)
	blood_particle.setup(true)
	blood_particle.global_position += rect_global_position
	
	if health <= 0:
		die()
	else:
		tween.interpolate_property(health_bar, "value", health_bar.value, (new_health/max_health)*100, 0.2, 
		Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()

func die():
	queue_free()
	emit_signal("player_died")
