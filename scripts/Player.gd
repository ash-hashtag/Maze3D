extends KinematicBody

var speed = 40
var mouse_sense = 0.1
var max_pitch = 50
var min_pitch = -50
var vel = Vector3()
var mocap = true

onready var main = get_parent()
onready var campivot = $CameraPivot
onready var cam = $CameraPivot/Camera

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _input(event):
	if event.is_action_pressed("ui_accept"):
		get_tree().reload_current_scene()
	
	if event.is_action_pressed("ui_cancel"):
		if mocap:
			mocap = false
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		else:
			mocap = true
			Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
		
	if event is InputEventMouse && mocap:
		if event.relative:
			rotation_degrees.y -= event.relative.x * mouse_sense
			campivot.rotation_degrees.x -= event.relative.y * mouse_sense
			campivot.rotation_degrees.x = clamp(campivot.rotation_degrees.x, min_pitch, max_pitch)
		
	
	var dir = Vector3.ZERO
	if event.is_action("ui_up"):
		dir -= transform.basis.z
	if event.is_action("ui_down"):
		dir += transform.basis.z
	if event.is_action("ui_right"):
		dir += transform.basis.x
	if event.is_action("ui_left"):
		dir -= transform.basis.x
	if event.is_action("up"):
		dir += transform.basis.y
	if event.is_action("down"):
		dir -= transform.basis.y
	dir = dir.normalized()
	vel  = vel.linear_interpolate(dir*speed, 1)
	vel = move_and_slide(vel, Vector3.UP)
