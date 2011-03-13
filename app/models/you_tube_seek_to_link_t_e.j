@implementation YouTubeSeekToLinkTE : ToolElement
{
  CPView m_container;
  CPString m_textTyped @accessors(property=linkText,readonly);
  CPString m_video_id  @accessors(property=videoId);
  int m_start_at_secs  @accessors(property=startAt);
  int m_end_at_secs    @accessors(property=endAt);
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementColorSupport addToClass:[self class]];
    [PageElementFontSupport addToClass:[self class]];

    m_textTyped     = _json.text;
    m_start_at_secs = [check_for_undefined(_json.start_at_secs, "0") intValue];
    m_end_at_secs   = [check_for_undefined(_json.end_at_secs, "0") intValue];
    m_video_id      = check_for_undefined(_json.video_id, nil);
    [self setFontFromJson];
    [self setColorFromJson];
  }
  return self;
}

- (void) controlTextDidEndEditing:(id)sender
{
  m_textTyped = [[sender object] stringValue];
  [self updateServer];
}

- (void) controlTextDidFocus:(id)sender
{
  [m_container setSelected:YES];
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !m_textTyped  ) {
    m_textTyped = "Enter Text Here";
  }

  m_container = container;

  if ( _mainView ) {
    [_mainView removeFromSuperview];
  }

  [self _setFont];
  _mainView = [[LPMultiLineTextField alloc] 
                initWithFrame:CGRectInset([container bounds], 4, 4)];
  [_mainView setFont:m_fontObj];
  [_mainView setTextColor:m_color];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setDelegate:self];
  [_mainView setScrollable:YES];
  [_mainView setEditable:YES];
  [_mainView setSelectable:YES];

  [_mainView setStringValue:m_textTyped];
  [container addSubview:_mainView];
}

- (CPImage)toolBoxImage
{
  if ( is_defined(_json.tool_image) ) {
    return [PlaceholderManager imageFor:_json.tool_image];
  } else {
    return [[PlaceholderManager sharedInstance] toolYouTube];
  }
}

@end

@implementation YouTubeSeekToLinkTE (PropertyHandling)

- (BOOL) hasProperties
{
  return YES;
}

- (void)openProperyWindow
{
  [[[PropertyYouTubeSeekToLinkTEController alloc]
     initWithWindowCibName:YouTubeSeekToLinkTEPropertyWindowCIB
               pageElement:self] showWindow:self];
}

- (void)setTextColor:(CPColor)aColor
{
  [self setColor:aColor];
  [_mainView setTextColor:aColor];
}

- (void) setLinkText:(CPString)aStringValue
{
  m_textTyped = aStringValue;
  [_mainView setStringValue:m_textTyped];
}

@end
