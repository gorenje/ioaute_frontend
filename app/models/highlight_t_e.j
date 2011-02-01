var PropertyList =
  [CPDictionary dictionaryWithObjectsAndKeys:
                      [@selector(setColor:), @selector(getColor)], "Color"];

@implementation HighlightTE : ToolElement
{
  int m_red;
  int m_blue;
  int m_green;
  float m_alpha;
  CPColor m_color;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [self setColorFromJson];

    if ( _json.width && _json.height ) {
      initialSize = CGSizeMake( _json.width, _json.height );
    } else {
      initialSize = CGSizeMake( 150, 35 );
    }
    m_color = [self createColor];
  }
  return self;
}

- (void)generateViewForDocument:(CPView)container
{
  if (_mainView) {
    [_mainView removeFromSuperview];
  }
  
  _mainView = [[CPView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setBackgroundColor:m_color];
  [container addSubview:_mainView];
}

- (CPImage)toolBoxImage
{
  if ( _json.image ) {
    return [PlaceholderManager imageFor:_json.image];
  } else {
    return [[PlaceholderManager sharedInstance] toolHighlight];
  }
}

- (BOOL) hasProperties
{
  return YES;
}

- (CPDictionary)getPropertyList
{
  return PropertyList;
}

- (void) setColor:(id)aValue
{
  var values = [aValue string].split(",");
  m_red = parseInt(values[0]);
  m_blue = parseInt(values[1]);
  m_green = parseInt(values[2]);
  m_alpha = parseFloat(values[3]);
  m_color = [self createColor];
  [_mainView setBackgroundColor:m_color];
  [self updateServer];
}

- (CPString)getColor
{
  return [CPString stringWithFormat:"%d, %d, %d, %f", m_red, m_blue, m_green, m_alpha];
}

@end

