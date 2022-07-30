@tool
extends Node
@onready @export var data : Resource:
	set(value):
		data = value
		update()
		if data != null and not data.is_connected("changed", update):
			data.connect("changed", update)

func _ready():
	update()

func _process(delta):
	pass

func update():
	var timer : float = Time.get_ticks_msec()
	for child in get_children():
		child.update(data)
	print(Time.get_ticks_msec() - timer)
