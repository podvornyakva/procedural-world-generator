@tool
extends Node

@export_range(0, 256) var divide : int = 6

var flag : int = divide
var resolution : int
var vertices_per_face : int

var vertices : = PackedVector3Array()
var normals : = PackedVector3Array()
var uv : = PackedVector2Array()
var indices : = PackedInt32Array()

var vertex_pairs : Array[int] = [0,1,0,2,0,3,0,4,1,2,2,3,3,4,4,1,5,1,5,2,5,3,5,4]
var edge_pairs : Array[int] = [0,1,4,1,2,5,2,3,6,3,0,7,8,9,4,9,10,5,10,11,6,11,8,7]
var base_directions : Array[Vector3] = [Vector3(0,1,0), Vector3(-1,0,0), Vector3(0,0,-1),
										Vector3(1,0,0), Vector3(0,0,1), Vector3(0,-1,0)]

var shader_code : String = ""

@onready var ramp : Gradient = preload("res://ramp.res")
@onready var noise : Noise = preload("res://noise.res")
@onready var noise_texture : NoiseTexture = preload("res://noise_texture.res")
@onready var shader : Shader = preload("res://shader.res")
@onready var material : ShaderMaterial = preload("res://material.res")
@onready var instance : MeshInstance3D = MeshInstance3D.new()


func _ready():
	
	generate_object()
	generate_sphere(divide, instance)
	add_child(instance)

func _process(delta):
	instance.rotate_y(0.5*delta)
	if flag != divide:
		generate_sphere(divide, instance)
		flag = divide

func generate_object():
	noise_texture.color_ramp = ramp
	noise_texture.noise = noise
	material.shader = shader
	material.shader.set_default_texture_param("noise_texture", noise_texture, 0)
	instance.mesh = ArrayMesh.new()

func generate_sphere(division : int, _instance: MeshInstance3D):

	var result = []
	result.resize(ArrayMesh.ARRAY_MAX)
	
	resolution = max(0, division)
	vertices_per_face = ((resolution + 3) * (resolution + 3) - (resolution + 3)) / 2
	
	vertices = base_directions
	normals = base_directions
	var u : float
	var v : float
	for i in range(0, base_directions.size()):
		u = atan2(vertices[i][0], vertices[i][2]) / (-2 * PI)
		if (u < 0):
			u += 1
		v = asin(vertices[i][1]) / PI + 0.5
		uv.push_back(Vector2(u, v))

	var edges : Array
	for i in range(0, vertex_pairs.size(), 2):
		var edge_start : = vertices[vertex_pairs[i]]
		var edge_end : = vertices[vertex_pairs[i+1]]
		
		var edge_vertex_indices : Array[int]
		edge_vertex_indices.resize(resolution + 2)
		edge_vertex_indices[0] = vertex_pairs[i]
		
		
		for resolution_index in range(0, resolution):
			var t : float = (resolution_index + 1.0) / (resolution + 1.0)
			edge_vertex_indices[resolution_index + 1] = vertices.size()
			var vertex : Vector3 = edge_start.slerp(edge_end, t)
			vertices.push_back(vertex)
			normals.push_back(vertex.normalized())
			u = atan2(vertex[0], vertex[2]) / (-2 * PI)
			if (u < 0):
				u += 1
			v = asin(vertex[1]) / PI + 0.5
			uv.push_back(Vector2(u, v))
		
		edge_vertex_indices[resolution + 1] = vertex_pairs[i + 1]

		#var edge_index : int = i / 2
		edges.push_back(edge_vertex_indices)

	for i in range(0, edge_pairs.size(), 3):
		var face_index : int  = i / 3
		var reverse : bool = (face_index >= 4)
		create_face(edges[edge_pairs[i]], edges[edge_pairs[i + 1]], edges[edge_pairs[i + 2]], reverse)
	result[ArrayMesh.ARRAY_VERTEX] = vertices
	result[ArrayMesh.ARRAY_NORMAL] = normals
	result[ArrayMesh.ARRAY_TEX_UV] = uv
	result[ArrayMesh.ARRAY_INDEX] = indices

	_instance.mesh.clear_surfaces()
	_instance.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, result)
	_instance.mesh.surface_set_material(0, material)

	print ("vertices: ",vertices.size(), " faces: ", indices.size()/3)
	indices.resize(0)
	vertices.resize(0)
	normals.resize(0)
	uv.resize(0)

func create_face(side_a: Array[int], side_b: Array[int], bottom: Array[int], reverse: bool):
	var vertices_per_edge : int = side_a.size()
	var vertex_map : Array[int]
	vertex_map.push_back(side_a[0])
	
	for i in range(1, vertices_per_edge - 1):
		vertex_map.push_back(side_a[i])

		var side_a_vertex : Vector3 = vertices[side_a[i]]
		var side_b_vertex : Vector3 = vertices[side_b[i]]
		
		var inner_vertices : int = i - 1
		var u : float
		var v : float
		for j in range(0, inner_vertices):
			var t : float = (j + 1.0) / (inner_vertices + 1.0)
			vertex_map.push_back(vertices.size())
			var vertex : Vector3 = side_a_vertex.slerp(side_b_vertex, t)
			vertices.push_back(vertex)
			normals.push_back(vertex.normalized())
			u = atan2(vertex[0], vertex[2]) / (-2 * PI)
			if (u < 0):
				u += 1
			v = asin(vertex[1]) / PI + 0.5
			uv.push_back(Vector2(u, v))
		vertex_map.push_back(side_b[i])
	
	for i in range(0, vertices_per_edge):
		vertex_map.push_back(bottom[i])

	var rows : int = resolution + 1
	for row in range(0, rows):
		var top_vertex : int = ((row + 1) * (row + 1) - row - 1) / 2
		var bottom_vertex : int = ((row + 2) * (row + 2) - row - 2) / 2

		var triangles_per_row : int = 1 + 2 * row
		for column in range(0, triangles_per_row):
			var v0: int
			var v1: int
			var v2: int
			if (column % 2 == 0):
				v0 = top_vertex
				v1 = bottom_vertex + 1
				v2 = bottom_vertex
				top_vertex += 1
				bottom_vertex += 1
			else:
				v0 = top_vertex
				v1 = bottom_vertex
				v2 = top_vertex - 1

			indices.push_back(vertex_map[v0])
			if (reverse):
				indices.push_back(vertex_map[v1])
				indices.push_back(vertex_map[v2])
			else:
				indices.push_back(vertex_map[v2])
				indices.push_back(vertex_map[v1])

#func _on_division_drag_ended(value_changed):
#	divide = $division.value

func _on_division_drag_ended(value_changed):
	if (value_changed):
		divide = $division.value
