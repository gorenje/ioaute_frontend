var PropertyList =
  [CPDictionary dictionaryWithObjectsAndKeys:
                      [@selector(setFontSize:), @selector(getFontSize)], "FontSize"];


@implementation HeaderTE : TextTE
{
  int m_fontSize;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    m_fontSize = _json.font_size;
  }
  return self;
}

- (void)generateViewForDocument:(CPView)container
{
  [super generateViewForDocument:container];
  [_textView setFont:[CPFont systemFontOfSize:m_fontSize]];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolText];
}

- (BOOL) hasProperties
{
  return YES;
}

- (CPDictionary)getPropertyList
{
  return PropertyList;
}

- (int) getFontSize
{
  return m_fontSize;
}

- (void) setFontSize:(CPString)value
{
  m_fontSize = parseInt(value);
  [_textView setFont:[CPFont systemFontOfSize:m_fontSize]];
  [self updateServer];
}


@end

