RSRC                     Shader            WD�TQ�
                                                  resource_local_to_scene    resource_name    code    script           res://shader.res �          Shader            shader_type spatial;
uniform sampler2D noise_texture : source_color,filter_linear_mipmap,repeat_enable;

void vertex(){
	vec3 vertex = VERTEX;
	VERTEX += texture(noise_texture, UV).rgb*NORMAL;
}


void fragment() {
	ALBEDO = vec3 (0,1,0.5)*texture(noise_texture, UV).rgb;
}
       RSRC