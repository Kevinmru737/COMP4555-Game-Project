extends Node2D

var cameras
var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
var current_cam
func _ready():
	cameras = get_tree().get_nodes_in_group("cameras")
	current_cam = get_viewport().get_camera_2d()
	print(current_cam.global_position)
func _process(_float):
	if Input.is_action_just_pressed("dialogic_default_action"):
		tween.tween_property(current_cam, "global_position", Vector2(1500, -290), 1)
		$CameraSwitcher.blend_to(cameras[0], 1)
		current_cam = get_viewport().get_camera_2d()
		print(current_cam.global_position)
	if Input.is_action_just_pressed("interact_object"):
		tween.tween_property(current_cam, "global_position", Vector2(1000, -290), 1)
		$CameraSwitcher.blend_to(cameras[1], 1)
		current_cam = get_viewport().get_camera_2d()
		print(current_cam.global_position)
