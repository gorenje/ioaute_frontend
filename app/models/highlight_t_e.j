@implementation HighlightTE : ToolElement
{
  CPString m_link_url @accessors(property=linkUrl);
  int m_is_clickable @accessors(property=clickable);
  int m_show_as_border @accessors(property=showAsBorder);
  int m_border_width @accessors(property=borderWidth);
  int m_when_visible @accessors(property=whenVisible);
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementColorSupport addToClass:[self class]];

    [self setColorFromJson];

    if ( typeof( _json.width ) != "undefined" && typeof( _json.height ) != "undefined" ) {
      initialSize = CGSizeMake( _json.width, _json.height );
    } else {
      initialSize = CGSizeMake( 150, 35 );
    }

    m_link_url       = _json.link_url;
    m_is_clickable   = _json.clickable;
    m_show_as_border = _json.show_as_border;
    m_border_width   = _json.border_width;
    m_when_visible   = _json.when_visible;

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

