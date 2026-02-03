extends Node2D

# System states
var control_rods = {
	"FineRod": {"position": 0, "actuated": false, "speed": "SLOW"},
	"SafetyRod1": {"position": 0, "actuated": false, "speed": "SLOW"},
	"SafetyRod2": {"position": 0, "actuated": false, "speed": "SLOW"},
	"CoarseRod": {"position": 0, "actuated": false, "speed": "SLOW"}
}

var radiation_monitors = {
	"Lab": {"level": 0.0, "status": "NORMAL"},
	"RxTop": {"level": 0.0, "status": "NORMAL"},
	"RxConsole": {"level": 0.0, "status": "NORMAL"},
	"Channel4": {"level": 0.0, "status": "NORMAL"}
}

var reactor_scram = false

# Alarm thresholds
var ALERT_THRESHOLD = 5.0  # mR/hr
var HIGH_THRESHOLD = 10.0   # mR/hr

func _ready():
	setup_control_rods()
	setup_radiation_monitors()
	setup_scram_button()
	update_all_displays()

func setup_control_rods():
	for rod in control_rods.keys():
		# Connect toggle switches
		var switch = get_node_or_null(rod + "Switch")
		if switch:
			switch.connect("pressed", _on_rod_switch_pressed.bind(rod))
		
		# Connect speed selectors if they exist
		var speed_switch = get_node_or_null(rod + "SpeedSwitch")
		if speed_switch:
			speed_switch.connect("pressed", _on_rod_speed_changed.bind(rod))

func setup_radiation_monitors():
	for channel in radiation_monitors.keys():
		update_radiation_display(channel)

func setup_scram_button():
	var scram = get_node_or_null("ScramButton")
	if scram:
		scram.connect("pressed", _on_scram_pressed)

func _on_rod_switch_pressed(rod_name):
	control_rods[rod_name]["actuated"] = !control_rods[rod_name]["actuated"]
	update_rod_display(rod_name)

func _on_rod_speed_changed(rod_name):
	if control_rods[rod_name]["speed"] == "SLOW":
		control_rods[rod_name]["speed"] = "FAST"
	else:
		control_rods[rod_name]["speed"] = "SLOW"
	update_rod_display(rod_name)

func update_rod_display(rod_name):
	# Update IN/OUT lights
	var in_light = get_node_or_null(rod_name + "InLight")
	var out_light = get_node_or_null(rod_name + "OutLight")
	var actuated_light = get_node_or_null(rod_name + "ActuatedLight")
	
	if control_rods[rod_name]["actuated"]:
		if actuated_light:
			actuated_light.modulate = Color.GREEN
		if in_light:
			in_light.modulate = Color.DARK_GRAY
		if out_light:
			out_light.modulate = Color.DARK_GRAY
	else:
		if actuated_light:
			actuated_light.modulate = Color.DARK_GRAY

func update_radiation_display(channel_name):
	var level = radiation_monitors[channel_name]["level"]
	var status = "NORMAL"
	
	if level >= HIGH_THRESHOLD:
		status = "HIGH"
	elif level >= ALERT_THRESHOLD:
		status = "ALERT"
	
	radiation_monitors[channel_name]["status"] = status
	
	# Update three-light system
	var normal_light = get_node_or_null(channel_name + "NormalLight")
	var alert_light = get_node_or_null(channel_name + "AlertLight")
	var high_light = get_node_or_null(channel_name + "HighLight")
	
	if normal_light:
		normal_light.modulate = Color.GREEN if status == "NORMAL" else Color.DARK_GRAY
	if alert_light:
		alert_light.modulate = Color.YELLOW if status == "ALERT" else Color.DARK_GRAY
	if high_light:
		high_light.modulate = Color.RED if status == "HIGH" else Color.DARK_GRAY

func _on_scram_pressed():
	reactor_scram = true
	# Drop all rods
	for rod in control_rods.keys():
		control_rods[rod]["actuated"] = false
		control_rods[rod]["position"] = 0
		update_rod_display(rod)
	
	# Visual feedback
	var scram_light = get_node_or_null("ScramLight")
	if scram_light:
		scram_light.modulate = Color.RED

func update_all_displays():
	for rod in control_rods.keys():
		update_rod_display(rod)
	for channel in radiation_monitors.keys():
		update_radiation_display(channel)
