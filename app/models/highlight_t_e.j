@implementation HighlightTE : ToolElement
{
  CPString m_link_url       @accessors(property=linkUrl);
  int m_is_clickable        @accessors(property=clickable);
  int m_show_as_border      @accessors(property=showAsBorder);
  int m_border_width        @accessors(property=borderWidth);

  int m_rotation            @accessors(property=rotation);
  int m_corner_top_left     @accessors(property=cornerTopLeft);
  int m_corner_top_right    @accessors(property=cornerTopRight);
  int m_corner_bottom_left  @accessors(property=cornerBottomLeft);
  int m_corner_bottom_right @accessors(property=cornerBottomRight);
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementColorSupport addToClass:[self class]];

    [self setColorFromJson];

    initialSize      = [self initialSizeFromJsonOrDefault:CGSizeMake( 150, 35 )];
    m_link_url       = check_for_undefined(_json.link_url, "");
    m_is_clickable   = [check_for_undefined(_json.clickable, "0" ) intValue];
    m_show_as_border = [check_for_undefined(_json.show_as_border, "0") intValue];
    m_border_width   = [check_for_undefined(_json.border_width, "3") intValue];

    m_rotation            = [check_for_undefined(_json.rotation, "0") intValue];
    m_corner_top_left     = [check_for_undefined(_json.corner_top_left, "0") intValue];
    m_corner_top_right    = [check_for_undefined(_json.corner_top_right, "0") intValue];
    m_corner_bottom_left  = [check_for_undefined(_json.corner_bottom_left, "0") intValue];
    m_corner_bottom_right = [check_for_undefined(_json.corner_bottom_right, "0") intValue];

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
  if ( is_undefined(_json.image) ) {
    return [[PlaceholderManager sharedInstance] toolHighlight];
  } else {
    return [PlaceholderManager imageFor:_json.image];
  }
}

- (BOOL)hasRoundedCorners
{
  return ( m_corner_top_left > 0 || m_corner_top_right > 0 ||
           m_corner_bottom_left > 0 || m_corner_bottom_right > 0 );
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

