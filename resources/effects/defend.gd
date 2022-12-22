extends "res://resources/effects/effects.gd"

static func trigger_effect(target, status):
	var expected_damage = target.damage_to_take
	var remaining_damage = expected_damage - status.effect_counter
	print("Remaining damage is =>", remaining_damage)
	target.set_damage_to_take(remaining_damage)
	
	# Reduce the stack amount 
	var stacks_remaining = max(status.effect_counter - expected_damage, 0)
	status.set_stack_count(stacks_remaining)

static func trigger_spoilage():
	pass
