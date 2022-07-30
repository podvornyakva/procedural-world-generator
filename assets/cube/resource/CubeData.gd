@tool
extends Resource
class_name CubeData

@export_range(2, 100) var resolution : int = 50:
	set(value):
		resolution = value
		emit_changed()
@export_range(1.0, 100.0) var radius : float = 1.0:
	set(value):
		radius = value
		emit_changed()	#emit_signal("changed")
@export_range(0.0, 10.0) var amplitude : float = 1.0:
	set(value):
		amplitude = value
		emit_changed()
@export var noise : Noise:
	set(value):
		noise = value
		emit_changed()
		if noise != null and not noise.is_connected("changed", update):
			noise.connect("changed", update)

func update():
	emit_changed()

func get_vertex(vector : Vector3) -> Vector3:
	var elevation = noise.get_noise_3dv(vector)
	elevation = 0.01 + (elevation + 1.0) / 2 * amplitude
	return vector * elevation * radius
