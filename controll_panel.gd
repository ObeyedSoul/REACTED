extends Node2D

var systems = {}

# Add this dictionary for system-specific colors
var system_colors = {
	"Reactor": Color.GREEN,
	"Coolant": Color.CYAN,
	"ControlRods": Color.YELLOW,
	"Emergency": Color.RED,
	"Turbine": Color.ORANGE,
	"Containment": Color.BLUE
}

var off_color = Color.DARK_GRAY

func _ready():
	# Auto-detect all buttons ending with "Button"
	for child in get_children():
		if child is Button and child.name.ends_with("Button"):
			var system_name = child.name.trim_suffix("Button")
			systems[system_name] = false
			child.connect("pressed", _on_button_pressed.bind(system_name))
	
	update_all_lights()

func _on_button_pressed(system_name):
	systems[system_name] = !systems[system_name]
	update_light(system_name)

func update_light(system_name):
	var light = get_node_or_null(system_name + "Light")
	if light:
		if systems[system_name]:
			# Use custom color if defined, otherwise default to GREEN
			light.modulate = system_colors.get(system_name, Color.GREEN)
		else:
			light.modulate = off_color

func update_all_lights():
	for system in systems.keys():
		update_light(system)
