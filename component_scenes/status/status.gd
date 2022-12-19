extends HBoxContainer

var effect_data

onready var status_counter = $StatusCounter/Sprite
onready var status_icon = $StatusIcon
onready var in_out_animation_player = $InOutAnimationPlayer

func setup(_effect_data, counter = 1):
	effect_data = _effect_data
	status_icon.texture = effect_data.effect_sprite
	status_counter.frame = counter
	in_out_animation_player.play("in")

func wipe_status():
	in_out_animation_player.play("out")
	yield(in_out_animation_player, "animation_finished")
	queue_free()
