extends Node2D

onready var equipment_container = $EquipmentContainer
onready var enemy_equipment_container = $EnemyEquipmentContainer
onready var enemy_container = $EnemyContainer
onready var equipment_animator = $EquipmentAnimator
onready var turn_button_animator = $TurnButtonAnimator
onready var player = $Player

var highlight_shader_material = preload("res://shaders/highlight_shader_material.tres")
var slot_machine_scene = preload("res://component_scenes/slot_machine/slot_machine.tscn")
var attacking_slot_machine = null
# This will eventually be passed in while setting up a combat 
var player_equipment = [preload("res://resources/equipment/test.tres")]
var enemy_intentions_locked = 0

func _ready():
	setup_player()
	setup_enemies()
	player_phase_cleanup()

func setup_player():
	for equipment in player_equipment:
		var slot_machine = slot_machine_scene.instance()
		equipment_container.add_child(slot_machine)
		slot_machine.setup(equipment, player)
		slot_machine.connect("attempting_to_acquire_target", self, "handle_targeting")

func setup_enemies():
	# TODO Eventually must fill enemy_container from passed data, just loop for now
	for enemy in enemy_container.get_children():
		enemy.connect("targeted", self, "handle_enemy_targeted")
		enemy.connect("intentions_locked_in", self, "handle_enemy_intentions_locked")
		
		for equipment in enemy.enemy_data.equipment:
			create_enemy_slot_machine(equipment, enemy)


func player_phase_begin():
	equipment_animator.play("heroEquipmentIn")
	turn_button_animator.play("enter")
	handle_start_of_player_turn_triggers()


func player_phase_cleanup():
	equipment_animator.play("heroEquipmentOut")
	turn_button_animator.play("exit")
	yield(turn_button_animator, "animation_finished")
	yield(handle_end_of_player_turn_triggers(), "completed")
	yield(get_tree().create_timer(1), "timeout")
	enemy_phase_begin()


func enemy_phase_begin():
	# Check for start of enemy turn triggers
	enemy_intentions_locked = 0
	# Slide in enemy slot machines
	equipment_animator.play("enemyEquipmentIn")
	yield(equipment_animator, "animation_finished")
	for enemy in enemy_container.get_children():
		enemy.spin_slot_machines()


# This method is called from handle_enemy_intentions_locked 
# once all enemy intentions have been provided
func enemy_phase_cleanup():
	equipment_animator.play("enemyEquipmentOut")
	yield(equipment_animator, "animation_finished")
	# Check for end of enemy turn triggers
	handle_end_of_enemy_turn_triggers()
	player_phase_begin()


func handle_start_of_player_turn_triggers():
	# Reset all slot machines for the player
	for slot_machine in equipment_container.get_children():
		slot_machine.refresh()
	
	# Check all statuses to see if they trigger on player turn start
	pass


func handle_end_of_player_turn_triggers():
	# TODO: Loop through all statuses for player end turn triggers
	yield(handle_all_enemy_intentions(), "completed")
	yield(get_tree(), "idle_frame")

func handle_all_enemy_intentions():
	for enemy in enemy_container.get_children():
		if enemy.intention_statuses.keys().size() > 0:
			yield(get_tree().create_timer(0.6), "timeout")
			handle_enemy_intentions(enemy)
	
	yield(get_tree(), "idle_frame")

func handle_end_of_enemy_turn_triggers():
	# For enemies
	for enemy in enemy_container.get_children():
		for status in enemy.statuses_container.get_children():
			if status.effect_data.trigger_at_end_enemy_turn:
				status.effect_data.effect_script.trigger_effect(enemy, status)
	
	# For allies
	for status in player.statuses_container.get_children():
		if status.effect_data.trigger_at_end_enemy_turn:
			status.effect_data.effect_script.trigger_effect(player, status)

func handle_enemy_intentions(_enemy):
	# Loop through all intentions
	var total_damage = 0
	var effect_index = 0
	for effect in _enemy.intention_statuses:
		total_damage += effect.effect_script.get_damage(_enemy.intention_statuses[effect])
		effect_index += 1
	
	_enemy.wipe_intention_statuses()
	
	if total_damage > 0:
		player.attacked(total_damage)


func create_enemy_slot_machine(equipment, enemy):
	var slot_machine = slot_machine_scene.instance()
	enemy_equipment_container.add_child(slot_machine)
	slot_machine.setup(equipment, enemy, true)
	slot_machine.connect("slot_machine_finished_rolling", enemy, "handle_slot_machine_finished_rolling")
	enemy.slot_machines.append(slot_machine)


func highlight_targets():
	for enemy in enemy_container.get_children():
		enemy.apply_new_material(highlight_shader_material)
		enemy.set_targetable(true)


func remove_highlight_from_enemies():
	for enemy in enemy_container.get_children():
		enemy.remove_material()
		enemy.set_targetable(false)


func disable_slot_machines_with_exceptions(exceptions):
	for equipment in equipment_container.get_children():
		if not equipment in exceptions:
			equipment.fully_disable()


func enable_slot_machines_with_exceptions(exceptions):
	for equipment in equipment_container.get_children():
		if not equipment in exceptions:
			equipment.fully_enable()

###################################
# SIGNAL TRIGGERED METHODS BELOW
###################################

# Signal from player slot machine
func handle_targeting(slot_machine):
	attacking_slot_machine = slot_machine
	highlight_targets()
	disable_slot_machines_with_exceptions([attacking_slot_machine])


# Signal from an enemy after being targeted with an attack
func handle_enemy_targeted(target):
	attacking_slot_machine.execute_on_target(target)
	attacking_slot_machine = null
	enable_slot_machines_with_exceptions([])
	remove_highlight_from_enemies()


func handle_enemy_intentions_locked():
	enemy_intentions_locked += 1
	
	if enemy_intentions_locked >= enemy_container.get_child_count():
		yield(get_tree().create_timer(0.8), "timeout")
		enemy_phase_cleanup()


func _on_EndTurnButton_pressed():
	player_phase_cleanup()
