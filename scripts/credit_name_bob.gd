extends Control

@export var bob_height: float = 12.0
@export var bob_speed: float = 3
#From Claude.ai
var credits = [
	{"category": "Programmed by:", "name": "Kevin Oh"},
	{"category": "Art by:", "name": "Alethea Tablante"},
	{"category": "Art by:", "name": "Katarina Holeksa"},
	{"category": "Art by:", "name": "Tashya Maraj"}
]

var credit_labels = []
var bob_times = []

func _ready():
	# Create grid layout
	var grid = GridContainer.new()
	grid.columns = 2
	grid.add_theme_constant_override("h_separation", 64)
	grid.add_theme_constant_override("v_separation", 64)
	add_child(grid)
	
	# Create credit entries
	for i in range(credits.size()):
		var credit_entry = VBoxContainer.new()
		credit_entry.alignment = BoxContainer.ALIGNMENT_CENTER
		grid.add_child(credit_entry)
		
		# Category label
		var category_label = Label.new()
		category_label.text = credits[i]["category"]
		category_label.add_theme_font_size_override("font_size", 30)
		category_label.add_theme_color_override("font_color", Color(0.46, 0.28, 0.16))
		category_label.add_theme_font_override("font", load("res://art/ui/fonts/BitDaylong11_sRB_.TTF"))
		credit_entry.add_child(category_label)
		
		# Name label
		var name_label = Label.new()
		name_label.text = credits[i]["name"]
		name_label.add_theme_font_size_override("font_size", 40)
		name_label.add_theme_color_override("font_color", Color(0.46, 0.28, 0.16))
		name_label.add_theme_font_override("font", load("res://art/ui/fonts/BitDaylong11_sRB_.TTF"))
		credit_entry.add_child(name_label)
		
		credit_labels.append(credit_entry)
		bob_times.append(0.0)
	
	# Center the grid
	grid.anchor_left = 0.5
	grid.anchor_top = 0.5
	grid.anchor_right = 0.5
	grid.anchor_bottom = 0.5
	grid.offset_left = -grid.size.x / 2
	grid.offset_top = -grid.size.y / 2

func _process(delta: float) -> void:
	for i in range(credit_labels.size()):
		bob_times[i] += delta
		
		# Stagger the animation by 0.5 seconds per person
		var time_offset = i * 0.2
		var bob_offset = sin((bob_times[i] + time_offset) * TAU / bob_speed) * bob_height
		
		var rect = credit_labels[i]
		rect.position.y = rect.position.y - bob_offset + sin(((bob_times[i] - delta) + time_offset) * TAU / bob_speed) * bob_height
