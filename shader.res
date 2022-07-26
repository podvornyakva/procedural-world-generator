RSRC                     Shader            �G���?]                                                  resource_local_to_scene    resource_name    code    script           res://shader.res �          Shader          �  shader_type spatial;
uniform sampler2D noise_texture : source_color,filter_linear_mipmap,repeat_enable;

struct vertex_data
{
	vec3 position;
	vec3 normal;
};

varying vec3 v_position;
varying vec3 v_normal;

vec3 get_height(){
	vec4 X = texture(noise_texture, v_position.zy); 
	vec4 Y = texture(noise_texture, v_position.xz);
	vec4 Z = texture(noise_texture, v_position.xy);
	vec3 blend = abs(v_normal);
	vec4 sample = X*blend.x+Y*blend.y+Z*blend.z;
	return sample.rgb;
}

void vertex(){
	v_position = VERTEX;
	v_normal = NORMAL;
	VERTEX += get_height()*0.1*NORMAL;
//	VERTEX += texture(noise_texture, UV).rgb*0.3*NORMAL;

}

void fragment() {
	ALBEDO = get_height();
//	ALBEDO = vec3 (0,1,0.5)*texture(noise_texture, UV).rgb;

}
       RSRC