@tool
extends Node

@export var vertices : int = 30

var goldenRatio : float = (1 + sqrt(5))/2
var increment : float = TAU * goldenRatio

var meshinstance = MeshInstance3D.new()
var light = DirectionalLight3D.new()
var camera = Camera3D.new()

var check: int = 0

func generate():
	var mesh_data = []
	mesh_data.resize(ArrayMesh.ARRAY_MAX)
	
	var vertices_array = PackedVector3Array()
	for i in range(vertices):
		var t : float = float(i) / vertices
		var angle1 : float = acos(1 - 2 * t)
		var angle2 : float = increment * i
		
		var x : float = sin(angle1) * cos(angle2)
		var y : float = sin(angle1) * sin(angle2)
		var z : float = cos(angle1)
		var vertex : Vector3 = Vector3(x,y,z)
		vertices_array.append(vertex)
	
	mesh_data[ArrayMesh.ARRAY_VERTEX] = vertices_array
	meshinstance.mesh.clear_surfaces()
	meshinstance.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, mesh_data)

func _ready():
	meshinstance.mesh = ArrayMesh.new()
	generate()
	camera.position.z = 2
	add_child(camera)
	add_child(light)
	add_child(meshinstance)
	
func _process(delta):
		if check != vertices:
			generate()
			check = vertices
			print("new value ", str(check))
