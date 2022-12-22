extends HBoxContainer

var effect_data
var effect_counter = 0

onready var status_counter = $StatusCounter/Sprite
onready var status_icon = $StatusIcon
onready var in_out_animation_player = $InOutAnimationPlayer
onready var tween = $Tween

func setup(_effect_data, counter = 1):
	effect_data = _effect_data
	status_icon.texture = effect_data.effect_sprite
	effect_counter = counter
	status_counter.frame = effect_counter
	yield(get_tree(), "idle_frame")
	animate_in()

func wipe_status():
	#in_out_animation_player.play("out")
	get_parent().get_parent().remove_status(effect_data)
	yield(animate_out(), "completed")
	queue_free()

func animate_out():
	var transparent = modulate
	var goal_pos_1 = rect_position
	goal_pos_1.y -= 10
	
	transparent.a = 0
	tween.interpolate_property(self, "modulate", modulate, transparent, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(self, "rect_position", rect_position, goal_pos_1, 0.6, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	yield(tween, "tween_all_completed")

func animate_in():
	var opaque = modulate
	opaque.a = 1
	var goal_pos_1 = self.rect_position
	goal_pos_1.y -= 4
	var goal_pos_2 = self.rect_position
	goal_pos_2.y += 2

	tween.interpolate_property(self, "modulate", modulate, opaque, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(self, "rect_position", rect_position, goal_pos_1, 0.3, Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.interpolate_property(self, "rect_position", goal_pos_1, goal_pos_2, 0.1, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.3)
	tween.interpolate_property(self, "rect_position", goal_pos_2, rect_position, 0.2, Tween.TRANS_LINEAR, Tween.EASE_IN, 0.4)
	tween.start()
	pass

func set_stack_count(count):
	effect_counter = count
	status_counter.frame = count
	
	if count <= 0:
		wipe_status()

func get_stack_count():
	return effect_counter
