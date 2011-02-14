@implementation HighlightTE : ToolElement

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementColorSupport addToClass:[self class]];

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
  if ( typeof(_json.image) != "undefined" ) {
    return [PlaceholderManager imageFor:_json.image];
  } else {
    return [[PlaceholderManager sharedInstance] toolHighlight];
  }
}

@end

@implementation HighlightTE (PropertyHandling)

- (BOOL) hasProperties
{
  return YES;
}

- (void)openProperyWindow
{
  [[[PropertyHighlightTEController alloc] initWithWindowCibName:HighlightTEPropertyWindowCIB
                                                    pageElement:self] showWindow:self];
}

- (void) setHighlightColor:(CPColor)aColor
{
  [self setColor:aColor];
  [_mainView setBackgroundColor:m_color];
}

@end

