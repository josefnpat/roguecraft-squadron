vec4 result;
extern vec2  outline;
extern vec3  color;

number alpha;

vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
{
    number alpha = 4*texture2D( texture, texturePos ).a;
    alpha += texture2D( texture, texturePos + vec2( outline.x, 0.0f ) ).a;
    alpha += texture2D( texture, texturePos + vec2( -outline.x, 0.0f ) ).a;
    alpha += texture2D( texture, texturePos + vec2( 0.0f, outline.y ) ).a;
    alpha += texture2D( texture, texturePos + vec2( 0.0f, -outline.y ) ).a;

    result = vec4( color.r, color.g, color.b, 0.5f * alpha );
    return result;
}