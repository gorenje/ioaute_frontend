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

@end

