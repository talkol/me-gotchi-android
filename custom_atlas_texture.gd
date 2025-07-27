tool
extends AtlasTexture
class_name CustomAtlasTexture
 
export var atlas_file_path: String = ""
export var region_rect: Rect2 = Rect2(0, 0, 0, 0)
export var margin_rect: Rect2 = Rect2(0, 0, 0, 0)
export var filter_clip_enabled: bool = false
export var reload: bool = false setget _set_reload
 
func _set_reload(value: bool) -> void:
	reload = false
	if Engine.editor_hint or not atlas_file_path.empty():
		_load_atlas()
 
func _init() -> void:
	if not atlas_file_path.empty():
		_load_atlas()
 
func _load_atlas() -> void:
	if atlas_file_path.empty():
		return
 
	var file = File.new()
	if file.open(atlas_file_path, File.READ) != OK:
		printerr("Failed to open file: " + atlas_file_path)
		return
 
	var buffer = file.get_buffer(file.get_len())
	file.close()
 
	var img = Image.new()
	var load_err: int
	if atlas_file_path.ends_with(".png.bin"):
		load_err = img.load_png_from_buffer(buffer)
	elif atlas_file_path.ends_with(".jpg.bin"):
		load_err = img.load_jpg_from_buffer(buffer)
	else:
		printerr("Unsupported file type: " + atlas_file_path)
		return
 
	if load_err != OK:
		printerr("Failed to load image from buffer")
		return
 
	var base_tex = ImageTexture.new()
	base_tex.create_from_image(img, Texture.FLAG_MIPMAPS | Texture.FLAG_FILTER | Texture.FLAG_REPEAT)  # Adjust flags
 
	atlas = base_tex
	region = region_rect
	margin = margin_rect
	filter_clip = filter_clip_enabled
 
	if Engine.editor_hint:
		emit_changed()
