extends Control

func _ready():
	$Buttons/FoodButton.connect("pressed", self, "_on_food_pressed")
	$Buttons/StatsButton.connect("pressed", self, "_on_stats_pressed")
	$Buttons/ActivitiesButton.connect("pressed", self, "_on_activities_pressed")
	$Buttons/Restart/RestartButton.connect("pressed", self, "_on_restart_pressed")
	State.connect("state_updated", self, "_on_state_updated")
	State.connect("state_emote", self, "_on_state_emote")
	_on_state_updated(State.state)

func _on_food_pressed():
	print("Food clicked")
	Utils.push_overlay(preload("res://screens/food.tscn"))

func _on_stats_pressed():
	print("Stats clicked")
	Utils.push_overlay(preload("res://screens/stats.tscn"))

func _on_activities_pressed():
	print("Activities clicked")
	Utils.push_overlay(preload("res://screens/activities.tscn"))

func _on_restart_pressed():
	print("Restart clicked")
	State.restart()

var last_minute = -1
var days_temp_changed = false
func _on_state_updated(state):
	if state.ran_away:
		$Face.visible = false
		$Header/DaysLabel.visible = false
		$Header/HeartsBar.visible = false
		$Header/StaminaBar.visible = false
		$Buttons/ActivitiesButton.visible = false
		$Buttons/FoodButton.visible = false
		$Buttons/StatsButton.visible = false
		$Buttons/Restart.visible = true
		$Name/Label.text = "RAN AWAY"
	else:
		$Face.visible = true
		$Header/DaysLabel.visible = true
		if !days_temp_changed:
			$Header/DaysLabel.text = str(int(state.days))
		$Header/HeartsBar.visible = true
		$Header/HeartsBar.update_value(int(state.hearts))
		$Header/StaminaBar.visible = true
		$Header/StaminaBar.value = int(state.stamina)
		$Buttons/ActivitiesButton.visible = true
		$Buttons/FoodButton.visible = true
		$Buttons/StatsButton.visible = true
		$Buttons/Restart.visible = false
		$Name/Label.text = Data.data.config.name
	$Background/Environment.texture = load("res://images/background" + str(1+int(state.days)%4) + ".jpg")
	$Background/Environment.position.x = round(OS.get_datetime().hour/23.0 * (get_viewport().size.x - $Background/Environment.texture.get_size().x * $Background/Environment.scale.x))
	if !days_temp_changed:
		var must_change = false
		var curr_minute = OS.get_datetime().minute
		if curr_minute != last_minute:
			last_minute = curr_minute
			must_change = true
		set_face_frame(int(state.hearts), must_change)

func _on_state_emote(message, happiness, no_energy):
	change_days_temporarily(message, happiness)
	if no_energy:
		blink_node($Header/StaminaBar)

func change_days_temporarily(temp_text: String, happiness, duration: float = 2.0):
	days_temp_changed = true
	$Header/DaysLabel.text = temp_text
	set_face_frame(happiness, true)
	yield(get_tree().create_timer(duration), "timeout")
	$Header/DaysLabel.text = str(int(State.state.days))
	set_face_frame(int(State.state.hearts), true)
	days_temp_changed = false

var curr_face_frame = -1 # frame is 0-8
func set_face_frame(happiness, must_change = false): # happiness 0-10 where 0 is least happy and 10 is most happy (0,1,2,3  4,5,6  7,8,9,10)	
	var happiness_to_frame = [8, 7, 7, 6, 3, 4, 5, 0, 1, 1, 2]
	var new_face_frame = happiness_to_frame[happiness]
	if must_change && new_face_frame == curr_face_frame:
		var face_frame_alt = [1, 2, 1, 4, 3, 4, 7, 8, 7]
		new_face_frame = face_frame_alt[new_face_frame]
	# convert face_frame to texture position
	var length = $Face.texture.get_size().x
	$Face.texture.region.position = Vector2(floor(new_face_frame % 3)*length, floor(new_face_frame/3)*length)
	curr_face_frame = new_face_frame

func blink_node(node: Node, blink_duration: float = 2.0, blink_interval: float = 0.4):
	if node.visible:
		var elapsed_time := 0.0
		while elapsed_time < blink_duration:
			node.visible = not node.visible
			yield(get_tree().create_timer(blink_interval), "timeout")
			elapsed_time += blink_interval
		node.visible = true  # ensure it's visible at the end
