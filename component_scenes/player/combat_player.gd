extends Control

const blood_particle_scene = preload("res://component_scenes/particles/blood_particles.tscn")
const status_scene = preload("res://component_scenes/status/status.tscn")

var max_health = 20
var health = max_health
var damage_to_take
var statuses = {}

onready var tween = $Tween
onready var health_bar = $HealthBar
onready var statuses_container = $StatusesContainer

signal player_died

func attacked(damage):
	damage_to_take = damage
	# Check for every status that triggers on attacked
	for status in statuses_container.get_children():
		if status.effect_data.trigger_at_attacked:
			status.effect_data.effect_script.trigger_effect(self, status)
	
	take_damage(damage_to_take)

func take_damage(damage):
	print("Player taking damage =>", damage)
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

func set_damage_to_take(new_damage):
	damage_to_take = new_damage

func die():
	queue_free()
	emit_signal("player_died")

func apply_status(effect, count):
	if effect in statuses:
		if effect.effect_script.is_stackable():
			var status = statuses[effect]
			status.set_stack_count(status.get_stack_count() + count)
	else:
		var status = status_scene.instance()
		statuses_container.add_child(status)
		status.setup(effect, count)
		
		statuses[effect] = status

func remove_status(effect):
	statuses.erase(effect)
