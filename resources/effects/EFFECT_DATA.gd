extends Resource

class_name EffectData

export (Script) var effect_script

# Following is used for statuses
export (Texture) var effect_sprite
export (bool) var apply_to_self = false
export (bool) var apply_to_target = true
export (bool) var trigger_at_start_player_turn = false
export (bool) var trigger_at_end_player_turn = false
export (bool) var trigger_at_start_enemy_turn = false
export (bool) var trigger_at_end_enemy_turn = false
export (bool) var trigger_at_attacked = false
export (bool) var trigger_at_attacking = false

export (bool) var lose_stack_at_start_player_turn = false
export (bool) var lose_stack_at_end_player_turn = false
export (bool) var lose_stack_at_start_enemy_turn = false
export (bool) var lose_stack_at_end_enemy_turn = false
export (bool) var lose_stack_at_attacked = false
export (bool) var lose_stack_at_attacking = false
