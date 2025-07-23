extends Control

var selected_item = null

func _ready():
	$Back/BackButton.connect("pressed", self, "_on_back_pressed")
	$Button.connect("pressed", self, "_on_button_pressed")
	$Background.color = Data.data.config.activities_bg_color
	$Title/Background.color = Data.data.config.activities_bg_color_dark
	
func _on_back_pressed():
	print("Back clicked")
	Utils.pop_overlay()

func _on_button_pressed():
	print("Big button clicked")
	State.had_item(selected_item.type, selected_item.like)
	Utils.pop_overlay()
	Utils.pop_overlay()

func set_selected_index(button_index):
	var i = button_index - 1
	selected_item = Data.data["activities"][i]
	$Button.texture_normal.region.position = Vector2(1024/3*(i%3), 1024/3*(i/3))
	$Title/Label.text = selected_item["name"].to_upper()
