@tool
extends Node

var goldenRatio : float = (1 + sqrt(5))/2
var increment : float = TAU * goldenRatio

# Определение переменной с возможностью доступа из панели редактора.
@export var vertices : int = 30000

# Объявление переменных с их последующим определением в момент загруки.
@onready var material : ShaderMaterial = ShaderMaterial.new()
@onready var instance : MeshInstance3D = MeshInstance3D.new()

# Исходный код шейдера.
var shader_code : String = "shader_type spatial;
							void vertex() {POINT_SIZE = 10.0;}
							void fragment() {ALBEDO = vec3(0,1,1);}"

# Флаг обновления переменной vertices.
var check: int = 0

func _ready():
	generate_material()
	generate_mesh()
	generate_mesh_data(instance)
	add_child(instance)

func _process(_delta):
		if check != vertices:
			generate_mesh_data(instance)
			check = vertices
			print("new value ", str(check))

func generate_material():
	material.shader = Shader.new()
	material.shader.set_code(shader_code)

func generate_mesh():
	instance.mesh = ArrayMesh.new()

func generate_mesh_data(mesh_instance: MeshInstance3D):
	var mesh_data = []
	mesh_data.resize(ArrayMesh.ARRAY_MAX)
	
	var vertices_array = PackedVector3Array()
	var normals_array = PackedVector3Array()
	for i in range(vertices):
		var t : float = float(i) / vertices
		var angle1 : float = acos(1 - 2 * t)
		var angle2 : float = increment * i
		
		var x : float = sin(angle1) * cos(angle2)
		var y : float = sin(angle1) * sin(angle2)
		var z : float = cos(angle1)
		vertices_array.push_back(Vector3(x,y,z))
		normals_array.push_back(Vector3(x,y,z))
	
	mesh_data[ArrayMesh.ARRAY_VERTEX] = vertices_array
	mesh_data[ArrayMesh.ARRAY_NORMAL] = normals_array
	mesh_instance.mesh.clear_surfaces()
	mesh_instance.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_POINTS, mesh_data)
	mesh_instance.mesh.surface_set_material(0,material)
