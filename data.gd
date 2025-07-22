extends Node

var data = load_data()

func load_data():
	var file = File.new()
	if file.file_exists("res://data/data.json"):
		file.open("res://data/data.json", File.READ)
		var json_text = file.get_as_text()
		file.close()

		var d = parse_json(json_text)
		if typeof(d) == TYPE_DICTIONARY:
			print("Loaded JSON:", d)
			return d
		else:
			print("Failed to parse JSON!")
	else:
		print("JSON file not found.")
