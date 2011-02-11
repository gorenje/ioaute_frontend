/*
 * Mixin for the support of foreground color.
 */
@implementation PageElementColorSupport : MixinHelper
{
  int m_red;
  int m_blue;
  int m_green;
  float m_alpha;
  CPColor m_color;
}

// assume that the _json object has already been set.
- (void)setColorFromJson 
{
  m_red   = _json.red;
  m_blue  = _json.blue;
  m_green = _json.green;
  m_alpha = _json.alpha;
  m_color = [self createColor];
}

- (void)setColor:(CPColor)aColor
{
  m_color = aColor;
  m_red   = Math.round([aColor redComponent] * 255);
  m_green = Math.round([aColor greenComponent] * 255);
  m_blue  = Math.round([aColor blueComponent] * 255);
  m_alpha = [aColor alphaComponent];
}

- (CPColor)getColor
{
  return m_color;
}

- (CPColor)createColor
{
  if ( m_red && m_green && m_blue && m_alpha ) {
    return [CPColor colorWith8BitRed:m_red green:m_green blue:m_blue alpha:m_alpha];
  } else {
    if ( self.m_defaultColor ) {
      return m_defaultColor;
    } else {
      return [CPColor blackColor];
    }
  }
}

@end
