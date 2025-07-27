tool  # Enables editor-time execution for previews
extends ImageTexture
class_name CustomImageTexture
 
export var file_path: String = ""
export var reload: bool = false setget _set_reload  # Button to force reload in inspector
 
func _set_reload(value: bool) -> void:
	reload = false
	if Engine.editor_hint or not file_path.empty():
		_load_texture()
 
func _init() -> void:
	if not file_path.empty():
		_load_texture()
 
func _load_texture() -> void:
	if file_path.empty():
		return
 
	var file = File.new()
	if file.open(file_path, File.READ) != OK:
		printerr("Failed to open file: " + file_path)
		return
 
	var buffer = file.get_buffer(file.get_len())
	file.close()
 
	var img = Image.new()
	var load_err: int
	if file_path.ends_with(".png.bin"):
		load_err = img.load_png_from_buffer(buffer)
	elif file_path.ends_with(".jpg.bin"):
		load_err = img.load_jpg_from_buffer(buffer)
	else:
		printerr("Unsupported file type: " + file_path)
		return
 
	if load_err != OK:
		printerr("Failed to load image from buffer")
		return
 
	# Create the texture (adjust flags as needed, e.g., for filtering/mipmaps)
	create_from_image(img, Texture.FLAG_MIPMAPS | Texture.FLAG_FILTER | Texture.FLAG_REPEAT)
 
	if Engine.editor_hint:
		# Force update for editor preview
		emit_changed()
