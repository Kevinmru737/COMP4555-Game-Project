extends Node2D
## Camera switching utility with blend and fade transitions
## Reference: https://www.manuelsanchezdev.com/blog/godot-camera-switcher
class_name CameraSwitcher

@onready var blend_cam: Camera2D = $BlendCam
@onready var fade_layer: CanvasLayer = $CanvasLayer
@onready var fade_rect: ColorRect = $CanvasLayer/ColorRect

var _current: Camera2D
var _adopted: Camera2D

func _ready() -> void:
	_current = _find_current_camera()
	_configure_fade(false, 0.0)
	# Safety: keep BlendCam internal and disabled
	if blend_cam.is_in_group("cameras"):
		blend_cam.remove_from_group("cameras")
	blend_cam.enabled = false
	# Initialize blend cam position to match current camera
	if _current:
		blend_cam.global_position = _current.global_position
		blend_cam.zoom = _current.zoom
		blend_cam.rotation = _current.rotation

## Remember the gameplay camera (nice for returning later)
func adopt(cam: Camera2D) -> void:
	_adopted = cam
	if cam:
		cut_to(cam)

## Instantly cut to target camera
func cut_to(target: Camera2D) -> void:
	if not target:
		return
	# Ensure previous camera is disabled before switching
	if _current and _current != target:
		_current.enabled = false
	target.enabled = true
	target.make_current()
	_current = target

## Smoothly blend from current to target camera over duration
func blend_to(target: Camera2D, duration: float = 0.7) -> void:
	if not target or target == _current:
		return
	
	# Get the actual current camera
	var current_cam = get_viewport().get_camera_2d()
	if not current_cam:
		cut_to(target)
		return
	
	# Match all properties from current camera
	blend_cam.global_position = current_cam.global_position
	blend_cam.zoom = current_cam.zoom
	blend_cam.rotation = current_cam.rotation
	blend_cam.limit_left = current_cam.limit_left
	blend_cam.limit_right = current_cam.limit_right
	blend_cam.limit_top = current_cam.limit_top
	blend_cam.limit_bottom = current_cam.limit_bottom
	
	if _current:
		_current.enabled = false
	blend_cam.enabled = true
	blend_cam.make_current()
	
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_OUT)
	tween.tween_property(blend_cam, "global_position", target.global_position, duration)
	tween.parallel().tween_property(blend_cam, "zoom", target.zoom, duration)
	tween.parallel().tween_property(blend_cam, "rotation", target.rotation, duration)
	
	await tween.finished
	cut_to(target)

## Fade to black, switch camera, then fade back in
func fade_to(target: Camera2D, fade_time: float = 0.25, hold: float = 0.0) -> void:
	if not target:
		return
	
	await _fade(1.0, fade_time)
	cut_to(target)
	
	if hold > 0.0:
		await get_tree().create_timer(hold).timeout
	
	await _fade(0.0, fade_time)

## Internal fade animation helper
func _fade(alpha: float, time: float) -> void:
	_configure_fade(true, fade_rect.modulate.a)
	var tween := create_tween().set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(fade_rect, "modulate:a", alpha, maxf(0.0, time))
	
	await tween.finished
	if alpha <= 0.0:
		_configure_fade(false, 0.0)

## Configure fade layer visibility and appearance
func _configure_fade(fade_visible: bool, alpha: float) -> void:
	fade_layer.visible = fade_visible or alpha > 0.0
	fade_rect.modulate = Color(0, 0, 0, alpha)
	fade_rect.size = get_viewport_rect().size

## Find the currently active camera in the scene
func _find_current_camera() -> Camera2D:
	# Prefer explicitly current cameras in "cameras" group
	for node in get_tree().get_nodes_in_group("cameras"):
		if node is Camera2D and node.is_current():
			return node
	
	# Fallback: first Camera2D found in the scene tree
	return find_child("*", true, false) as Camera2D
