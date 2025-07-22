extends Control

func _ready():
	State.connect("state_updated", self, "_on_state_updated")
	_on_state_updated(State.state)

func _on_state_updated(state):
	$ProgressBar.value = int(state.sleep_progress)
	if state.sleep_progress >= 10:
		Utils.pop_overlay()
