@implementation HighlightTE : ToolElement
{
  CPString m_link_url @accessors(property=linkUrl);
  int m_is_clickable @accessors(property=clickable);
  int m_show_as_border @accessors(property=showAsBorder);
  int m_border_width @accessors(property=borderWidth);
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementColorSupport addToClass:[self class]];

    [self setColorFromJson];

    if ( is_defined( _json.width ) && is_defined( _json.height ) ) {
      initialSize = CGSizeMake( _json.width, _json.height );
    } else {
      initialSize = CGSizeMake( 150, 35 );
    }

    m_link_url       = check_for_undefined(_json.link_url, "");
    m_is_clickable   = parseInt(check_for_undefined(_json.clickable, "0" ));
    m_show_as_border = parseInt(check_for_undefined(_json.show_as_border, "0"));
    m_border_width   = parseInt(check_for_undefined(_json.border_width, "3"));

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

