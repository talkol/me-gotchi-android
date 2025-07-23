extends Control

func _ready():
	$Back/BackButton.connect("pressed", self, "_on_back_pressed")
	$Buttons/GridContainer/Button1.connect("pressed", self, "_on_button_pressed", [1])
	$Buttons/GridContainer/Button2.connect("pressed", self, "_on_button_pressed", [2])
	$Buttons/GridContainer/Button3.connect("pressed", self, "_on_button_pressed", [3])
	$Buttons/GridContainer/Button4.connect("pressed", self, "_on_button_pressed", [4])
	$Buttons/GridContainer/Button5.connect("pressed", self, "_on_button_pressed", [5])
	$Buttons/GridContainer/Button6.connect("pressed", self, "_on_button_pressed", [6])
	$Buttons/GridContainer/Button7.connect("pressed", self, "_on_button_pressed", [7])
	$Buttons/GridContainer/Button8.connect("pressed", self, "_on_button_pressed", [8])
	$Buttons/GridContainer/Button9.connect("pressed", self, "_on_button_pressed", [9])
	$Background.color = Data.data.config.food_bg_color
	$Title/Background.color = Data.data.config.food_bg_color_dark
	
func _on_back_pressed():
	print("Back clicked")
	Utils.pop_overlay()

func _on_button_pressed(button_index):
	print("Button ", button_index, " clicked")
	var overlay = Utils.push_overlay(preload("res://screens/food_item.tscn"))
	overlay.set_selected_index(button_index)
