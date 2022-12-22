extends "res://resources/effects/effects.gd"

static func trigger_effect(target, status):
	var bleed_damage = status.get_stack_count()
	target.take_damage(bleed_damage)
	
	# Reduce the stack amount 
	var stacks_remaining = max(status.effect_counter - 1, 0)
	status.set_stack_count(stacks_remaining)

static func trigger_spoilage():
	pass
