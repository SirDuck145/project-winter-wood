#tool
extends ScrollContainer

var faces
var scroll_speed = 0
var max_scroll_speed = 400
var max_scroll = 9999999999999999
var frame_height_offset = 48 + 4
var frame_width = 48
var spinning = false
var currently_stopping = false
var scroll_index_to_stop_at = -1

var should_stop_self = true
var time_until_stopping = 1
var time_elapsed = 0.0
var time_until_max_scroll = 0.35

var face_scene = preload("res://component_scenes/slot_machine/face.tscn")
var stopping_particle_scene = preload("res://component_scenes/slot_machine/stopping_particles.tscn")

var active_frame = null


onready var tween = $Tween
onready var face_container = $FaceContainer

signal start_stopping
signal finished_rolling

func _process(delta):
	if should_stop_self && !currently_stopping && spinning:
		time_elapsed += delta
		if time_elapsed >= time_until_stopping:
			end_on_random_frame()
	
	if spinning && scroll_index_to_stop_at >= 0:
		var last_scroll = scroll_vertical
		var new_scroll = scroll_vertical - delta * scroll_speed
		if new_scroll <= 0:
			new_scroll = max_scroll
		
		scroll_vertical = new_scroll
		if (new_scroll <= scroll_index_to_stop_at && scroll_index_to_stop_at <= last_scroll or new_scroll >= last_scroll && last_scroll >= scroll_index_to_stop_at):
			emit_signal('start_stopping')
			spinning = false
	
	else:
		scroll_vertical -= delta * scroll_speed
		
		if scroll_vertical <= 0:
			scroll_vertical = max_scroll

func setup(entries, _should_stop_self):
	faces = entries
	should_stop_self = _should_stop_self
	for face in faces:
		var face_display = face_scene.instance()
		face_display.texture = face.face_sprite
		face_container.add_child(face_display)
	
	# Add a duplicated final frame at the start of the face container
	var face_display = face_scene.instance()
	face_display.texture = faces[faces.size()-1].face_sprite
	face_container.add_child(face_display)
	face_container.move_child(face_display, 0)

func start_spinning():
	tween.interpolate_property(self, "scroll_speed",
		0, max_scroll_speed, time_until_max_scroll,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	spinning = true
	scroll_index_to_stop_at = -1
	time_elapsed = 0.0
	currently_stopping = false
	active_frame = null

func end_on_random_frame():
	var index = randi()%(face_container.get_child_count()-1)
	var index_to_stop_at = index + 1
	
	if index == 0:
		active_frame = faces[face_container.get_child_count() - 2]
	else:
		active_frame = faces[index-1]
	
	scroll_index_to_stop_at = frame_height_offset * index_to_stop_at
	currently_stopping = true
	yield(self, "start_stopping")
	scroll_speed = 0
	spinning = false
	scroll_to_frame_index(frame_height_offset * index)

func scroll_to_frame_index(target_scroll_value):
	tween.interpolate_property(self, "scroll_vertical",
		scroll_vertical, target_scroll_value, 0.3,
		Tween.TRANS_LINEAR, Tween.EASE_IN)
	tween.start()
	
	yield(tween, "tween_completed")
	currently_stopping = false
	var particle = stopping_particle_scene.instance()
	get_tree().root.add_child(particle)
	particle.position = Vector2(rect_global_position.x + frame_width/2, rect_global_position.y + frame_width/2)
	emit_signal("finished_rolling")

func get_active_frame_data():
	return active_frame
