//'Two-Strip Technicolor Inspired Look' shader by EHCB, CC0 licensed

shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_linear;
uniform float red_boost : hint_range(1.0, 1.5, 0.1) = 1.2;
uniform float green_boost : hint_range(1.0, 1.5, 0.1) = 1.1;

void fragment() {
    //grab the screen texture
    vec4 screen = texture(screen_texture, SCREEN_UV);
    //average out the blue and green channels.
    float halfway = (screen.b + screen.g)/2.0;
    //apply the boosts and make the blacks slightly green
    screen.b = halfway;
    screen.g = max(halfway*green_boost,0.05);
    screen.r = screen.r*red_boost;
    COLOR = screen;
}
