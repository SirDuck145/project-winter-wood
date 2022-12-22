extends Resource

class_name EffectData

export (Script) var effect_script

# Following is used for statuses
export (Texture) var effect_sprite
export (bool) var apply_to_self = false
export (bool) var apply_to_target = true
export (Globals.EFFECT_TRIGGERS) var effect_trigger
export (Globals.SPOILAGE_TRIGGERS) var spoilage_trigger
