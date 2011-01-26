@implementation HighlightTE : ToolElement
{
  int m_red;
  int m_blue;
  int m_green;
  float m_alpha;

  CPColor m_bgColor;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    m_red = _json.red;
    m_blue = _json.blue;
    m_green = _json.green;
    m_alpha = _json.alpha;
    
    m_bgColor = [CPColor colorWith8BitRed:m_red green:m_green blue:m_blue alpha:m_alpha];
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
  [_mainView setBackgroundColor:m_bgColor];
  [container addSubview:_mainView];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolMoustache];
}

@end
