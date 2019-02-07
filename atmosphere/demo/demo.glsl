uniform vec3 camera;
uniform float exposure;
uniform vec3 white_point;
uniform vec3 earth_center;
uniform vec3 sun_direction;
uniform vec2 sun_size;
in vec3 view_ray;
layout(location = 0) out vec4 color;

vec3 GetSolarLuminance();
vec3 GetSkyLuminance(vec3 camera, vec3 view_ray, float shadow_length,
                     vec3 sun_direction, out vec3 transmittance);

void main() {
  // Normalized view direction vector.
  float phi=-view_ray.x*3.14159265,
        theta=view_ray.y/2*3.14159265;
  vec3 view_direction=vec3(cos(phi)*cos(theta),
                           sin(phi)*cos(theta),
                                  1*sin(theta));
  // Tangent of the angle subtended by this fragment.
  float fragment_angular_size =
      length(dFdx(view_direction) + dFdy(view_direction));

  // Compute the radiance of the sky.
  vec3 transmittance;
  vec3 radiance = GetSkyLuminance(
      camera - earth_center, view_direction, 0, sun_direction, transmittance);

  // If the view ray intersects the Sun, add the Sun radiance.
  if (dot(view_direction, sun_direction) > sun_size.y)
    radiance += transmittance * GetSolarLuminance();

  color.rgb = pow(radiance / white_point * exposure, vec3(1.0 / 2.2));
  color.a = 1.0;
}
