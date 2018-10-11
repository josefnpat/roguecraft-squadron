vec4 result;
extern vec2  outline;
extern vec3  color;

number alpha;

#define LAYERS 4
#define ALPHA_MULT (3*3-1)*LAYERS

vec4 effect( vec4 col, Image texture, vec2 texturePos, vec2 screenPos )
{
    alpha = ALPHA_MULT*texture2D( texture, texturePos ).a;
    for (int layer=1; layer < LAYERS; layer++){
      number layer_mult_x = outline.x*layer/LAYERS;
      number layer_mult_y = outline.y*layer/LAYERS;
      for (int x=-1; x <=1; x++){
        for (int y=-1; y<= 1; y++ ){
          if (x != 0 && y != 0){
            alpha += texture2D( texture, texturePos + vec2(x*layer_mult_x,y*layer_mult_y) ).a;
          }
        }
      }
    }
    result = vec4( color.r, color.g, color.b, alpha/ALPHA_MULT );
    return result;
}
