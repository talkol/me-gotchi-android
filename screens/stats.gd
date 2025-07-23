extends Control

func _ready():
	$Back/BackButton.connect("pressed", self, "_on_back_pressed")
	State.connect("state_updated", self, "_on_state_updated")
	$Background.color = Data.data.config.favorite_color_light
	$Title/Background.color = Data.data.config.favorite_color
	_on_state_updated(State.state)

func _on_back_pressed():
	print("Back clicked")
	queue_free()

func _on_state_updated(state):
	$Stats/ColumnsContainer/ProgressBarsContainer/MarginContainer1/ProgressBar1.value = int(state.food)
	$Stats/ColumnsContainer/ProgressBarsContainer/MarginContainer2/ProgressBar2.value = int(state.drink)
	$Stats/ColumnsContainer/ProgressBarsContainer/MarginContainer3/ProgressBar3.value = int(state.fun)
	$Stats/ColumnsContainer/ProgressBarsContainer/MarginContainer4/ProgressBar4.value = int(state.exercise)
	$Stats/ColumnsContainer/ProgressBarsContainer/MarginContainer5/ProgressBar5.value = int(state.sleep)
