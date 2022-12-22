extends Control

const status_scene = preload("res://component_scenes/status/status.tscn")
const blood_particle_scene = preload("res://component_scenes/particles/blood_particles.tscn")

var enemy_data = preload("res://resources/enemies/thug.tres")
var max_health = enemy_data.health
var health = max_health
var intention_statuses = {}
var statuses = {}
var slot_machines = []
var slot_machines_rolling = 0

onready var background_sprite = $Background
onready var character_sprite = $Character
onready var border_sprite = $Border
onready var targetable_button = $TargetableButton
onready var health_bar = $HealthBar
onready var tween = $Tween
onready var intention_statuses_container = $IntentionStatuses
onready var statuses_container = $Statuses

signal targeted
signal enemy_died
signal intentions_locked_in

func apply_new_material(new_material):
	background_sprite.material = new_material
	character_sprite.material = new_material
	border_sprite.material = new_material

func remove_material():
	background_sprite.material = null
	character_sprite.material = null
	border_sprite.material = null

func set_targetable(can_target):
	if can_target:
		make_targetable()
	else:
		make_untargetable()

func make_targetable():
	targetable_button.visible = true

func make_untargetable():
	targetable_button.visible = false

func _on_TargetableButton_pressed():
	emit_signal("targeted", self)

func take_damage(damage):
	var new_health = health - damage
	health -= damage
	
	var blood_particle = blood_particle_scene.instance()
	get_tree().root.add_child(blood_particle)
	blood_particle.setup(false)
	blood_particle.global_position += rect_global_position
	
	
	if health <= 0:
		die()
	else:
		tween.interpolate_property(health_bar, "value", health_bar.value, (new_health/max_health)*100, 0.2, 
		Tween.TRANS_LINEAR, Tween.EASE_IN)
		tween.start()

func handle_slot_machine_finished_rolling(slot_machine):
	slot_machines_rolling -= 1
	
	var face_datas = slot_machine.get_frame_statuses()
	for face_data in face_datas:
		var effect_index = 0
		for effect in face_data.effects:
			if effect in intention_statuses:
				if effect.effect_script.is_stackable():
					intention_statuses[effect] += face_data.effects_weights[effect_index]
			else:
				intention_statuses[effect] = face_data.effects_weights[effect_index]
			
			effect_index += 1
	
	if slot_machines_rolling <= 0:
		for intention in intention_statuses:
			var status = status_scene.instance()
			intention_statuses_container.add_child(status)
			status.setup(intention, intention_statuses[intention])
		
		emit_signal("intentions_locked_in")

func wipe_intention_statuses():
	intention_statuses = {}
	for child in intention_statuses_container.get_children():
		child.wipe_status()
		yield(get_tree().create_timer(0.1), "timeout")

func spin_slot_machines():
	slot_machines_rolling = 0
	
	for slot_machine in slot_machines:
		slot_machine.spin_nonlocked_frames()
		slot_machines_rolling += 1
	pass

func die():
	for slot_machine in slot_machines:
		slot_machine.queue_free()
	queue_free()
	emit_signal("enemy_died")

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
