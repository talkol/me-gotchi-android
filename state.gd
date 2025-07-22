extends Node

signal state_updated(new_state)
signal state_emote(message, happiness, no_energy)
var state = null

func now():
	return OS.get_unix_time()

func init_state():
	state = {
		"born": now(),
		"last_food": int(now() - 0.2*Data.data.config.food_empty_seconds), # start food at 8
		"food": int(10),
		"last_drink": int(now() - 0.2*Data.data.config.drink_empty_seconds), # start drink at 8
		"drink": int(10),
		"last_fun": int(now() - 0.2*Data.data.config.fun_empty_seconds), # start fun at 8
		"fun": int(10),
		"last_exercise": int(now() - 0.2*Data.data.config.exercise_empty_seconds), # start exercise at 8
		"exercise": int(10),
		"last_sleep": now(),
		"sleep": int(10),
		"last_stamina": now(),
		"stamina": int(10),
		"last_zero_hearts": now(),
		"ran_away": false,
		"sleep_started": now(),
		"sleep_progress": int(0),
		# views
		"hearts": int(10),
		"days": int(1)
	}
	
func update_views(timestamp):
	if state != null:
		print("State before update views: ",state)
		state.days = 1 + floor((timestamp - state.born) / Data.data.config.day_seconds)
		state.food = max(0, round(10 - 10 * (timestamp - state.last_food) / Data.data.config.food_empty_seconds))
		state.drink = max(0, round(10 - 10 * (timestamp - state.last_drink) / Data.data.config.drink_empty_seconds))
		state.fun = max(0, round(10 - 10 * (timestamp - state.last_fun) / Data.data.config.fun_empty_seconds))
		state.exercise = max(0, round(10 - 10 * (timestamp - state.last_exercise) / Data.data.config.exercise_empty_seconds))
		state.sleep = max(0, round(10 - 10 * (timestamp - state.last_sleep) / Data.data.config.sleep_empty_seconds))
		state.hearts = min(state.food, min(state.drink, min(state.fun, min(state.exercise, state.sleep))))
		if state.hearts != 0:
			state.last_zero_hearts = timestamp
		if (1 + floor((timestamp - state.last_zero_hearts) / Data.data.config.day_seconds) >= 4):
			state.ran_away = true
		var stamina_gain = round((timestamp - state.last_stamina) / float(Data.data.config.stamina_full_seconds) * 10.0)
		if stamina_gain > 0:
			state.stamina = min(10, state.stamina + stamina_gain)
			state.last_stamina = timestamp
		state.sleep_progress = min(10, round(10 * (timestamp - state.sleep_started) / Data.data.config.sleep_full_seconds))
		print("State after update views: ",state)

func had_item(type, like):
	var now = now()
	print("Had item: ", type, " ", like)
	var stamina_cost = int(Data.data.config["stamina_for_" + type])
	if state.stamina < stamina_cost:
		emit_signal("state_emote", "NO ENERGY", 5, true)
		return
	else:
		state.stamina = state.stamina - stamina_cost
		state.last_stamina = now
	if like:
		state["last_" + type] = now
		state[type] = 10
		_refresh_state()
		if type == "food" || type == "drink":
			emit_signal("state_emote", "YUM!", 10, false)
		if type == "fun" || type == "exercise":
			emit_signal("state_emote", "FUN!", 10, false)
		if type == "sleep":
			emit_signal("state_emote", "ZZZ..", 10, false)
			yield(get_tree().create_timer(2.0), "timeout")
			state.sleep_started = now
			state.sleep_progress = 0
			Utils.push_overlay(preload("res://screens/sleep.tscn"))
	else:
		_refresh_state()
		if type == "food" || type == "drink":
			emit_signal("state_emote", "YUCK!", 1, false)
		if type == "fun" || type == "exercise":
			emit_signal("state_emote", "BORING!", 1, false)
	
func _ready():
	load_state()
	var timer = Timer.new()
	timer.wait_time = 10 # tick time in seconds
	timer.one_shot = false
	timer.autostart = true
	add_child(timer)
	timer.connect("timeout", self, "_refresh_state")
	_refresh_state()

func _refresh_state():
	var timestamp = now()
	print("_refresh_state: ",timestamp)
	update_views(timestamp)
	save_state()
	emit_signal("state_updated", state)

func restart():
	init_state()
	_refresh_state()

# handle app going to foreground and background in Android
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_FOCUS_OUT:
		print("App lost focus – pausing game tree.")
		get_tree().paused = true

	elif what == MainLoop.NOTIFICATION_WM_FOCUS_IN:
		print("App gained focus – resuming game tree.")
		get_tree().paused = false
		_refresh_state()

func load_state():
	if state == null:
		var file = File.new()
		if not file.file_exists("user://state.json"):
			print("Save file not found!")
			init_state()
			return
		var error = file.open("user://state.json", File.READ)
		if error != OK:
			print("Failed to load!")
			init_state()
			return
		var d = file.get_as_text()
		var s = parse_json(d)
		if typeof(s) != TYPE_DICTIONARY:
			print("Invalid save file!")
			init_state()
			return
		state = s
		print("Loaded state: ", s)
		file.close()

func save_state():
	if state != null:
		var file = File.new()
		var error = file.open("user://state.json", File.WRITE)
		if error != OK:
			print("Failed to save!")
			return
		file.store_string(to_json(state))
		file.close()
		print("Saved state: ", state)
