extends Control

var list = []
var path = "res://test_levels/"
@onready var level_list = $LevelList
@onready var game_manager = get_tree().get_first_node_in_group("GameManager")

func _on_button_pressed() -> void:
	$ShowLevelsButton.hide()
	$LevelList.show()
	list = get_level_list()
	populate_level_list()



func populate_level_list() -> void:
	for level in list:
		level_list.add_item(level)

# Grabs the files names of the levels to be used
func get_level_list() -> PackedStringArray:
	path = "res://test_levels/"
	var files : PackedStringArray = []
	var dir = DirAccess.open(path)
	
	if dir:
		files = dir.get_files()
	else:
		print("error occurred grabbing test level files")
	
	return files


func _on_level_list_item_activated(index: int) -> void:
	var scene_path = path + list[index]
	var level_scene = load(scene_path)
	var activated_indicator = Label.new()
	activated_indicator.text = list[index]
	activated_indicator.position = Vector2(1500,-900)
	activated_indicator.z_index = 10
	add_child(activated_indicator)
	
	print("activated list item")
	if level_scene:
		game_manager.scene_list.push_front(scene_path)
		#print("error instantiating test level")	
	
