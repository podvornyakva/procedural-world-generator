@tool
extends MeshInstance3D
@export var base : Vector3
signal change

func update(data : CubeData):
	
	
	
	var array : Array
	array.resize(ArrayMesh.ARRAY_MAX)
	var vertex : = PackedVector3Array()
	var normal : = PackedVector3Array()
	var normal2 : = PackedVector3Array()
	var uv : = PackedVector2Array()
	var index : = PackedInt32Array()
	
	var resolution : int = data.resolution
	var vertices : int = resolution * resolution
	var indices : int = (resolution - 1) * (resolution - 1) * 6
	
	vertex.resize(vertices)
	normal.resize(vertices)
	normal2.resize(vertices)
	uv.resize(vertices)
	index.resize(indices)
	
	var face : int = 0
	var side_a : Vector3 = Vector3(base.y, base.z, base.x)
	var side_b : Vector3 = base.cross(side_a)

	for y in range(resolution):
		for x in range(resolution):
			var id : int = x + y * resolution
			var percent : Vector2 = Vector2(x, y) / (resolution - 1)
			var on_cube : Vector3 = (base + (percent.x - 0.5) * 2.0 * side_a + (percent.y - 0.5) * 2.0 * side_b).normalized()
			vertex[id] = data.get_vertex(on_cube)
			normal[id] = on_cube
			if x != resolution - 1 and y != resolution - 1:
				index[face+2] = id
				index[face+1] = id + resolution + 1
				index[face] = id + resolution
				
				index[face+5] = id
				index[face+4] = id + 1
				index[face+3] = id + resolution + 1
				
				face += 6

#	for a in range(0, index.size(), 3):
#		var b : int = a + 1
#		var c : int = a + 2
#		var ab : Vector3 = vertex[index[b]] - vertex[index[a]]
#		var bc : Vector3 = vertex[index[c]] - vertex[index[b]]
#		var ca : Vector3 = vertex[index[a]] - vertex[index[c]]
#		var ab_bc : Vector3 = ab.cross(bc) * - 1.0
#		var bc_ca : Vector3 = bc.cross(ca) * - 1.0
#		var ca_ab : Vector3 = ca.cross(ab) * - 1.0
#		normal2[index[a]] += ab_bc + bc_ca + ca_ab
#		normal2[index[b]] += ab_bc + bc_ca + ca_ab
#		normal2[index[c]] += ab_bc + bc_ca + ca_ab
#		
#	for i in normal2:
#		i = i.normalized()

	array[ArrayMesh.ARRAY_VERTEX] = vertex
	array[ArrayMesh.ARRAY_NORMAL] = normal
	array[ArrayMesh.ARRAY_TEX_UV] = uv
	array[ArrayMesh.ARRAY_INDEX] = index
	
	call_deferred("update_mesh", array)
	
	print("Vertices: ", vertex.size(), " Triangles: ", index.size()/3)

func update_mesh(array : Array):
	if not mesh:
		self.mesh = ArrayMesh.new()
	mesh.clear_surfaces()
	self.mesh.add_surface_from_arrays(Mesh.PRIMITIVE_TRIANGLES, array)
	
func _ready():
	pass # Replace with function body.

func _process(delta):
	pass
