@implementation PageElementFontSupport : MixinHelper
{
  float m_fontSize;
  CPString m_fontName;
}

- (void)setFontFromJson
{
  m_fontSize  = _json.font_size;
  m_fontName  = _json.font_name;
  // TODO support more features, basically everything that is configurable in CPFont.j
  [self _setFont];
}

- (void)_setFont
{
  if ( !m_fontSize ) m_fontSize = 12;
  if ( m_fontName ) {
    m_fontObj = [CPFont fontWithName:m_fontName size:m_fontSize];
  } else {
    m_fontObj = [CPFont systemFontOfSize:m_fontSize]
  }
}

- (float) getFontSize
{
  return m_fontSize;
}

- (CPString) getFontName
{
  return m_fontName;
}

- (void)setFontSize:(float)value
{
  m_fontSize = value;
  [self _setFont];
  [_mainView setFont:m_fontObj];
}

- (void)setFontName:(CPString)aName
{
  m_fontName = aName;
  [self _setFont];
  [_mainView setFont:m_fontObj];
}

- (void)setFont:(CPFont)aFont
{
  m_fontSize = [aFont size];
  m_fontName = [aFont familyName];
  m_fontObj  = aFont;
  [_mainView setFont:m_fontObj];
}

@end
