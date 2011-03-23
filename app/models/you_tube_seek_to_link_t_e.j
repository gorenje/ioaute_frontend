@implementation YouTubeSeekToLinkTE : ToolElement
{
  CPString m_textTyped @accessors(property=textTyped);
  CPString m_video_id  @accessors(property=videoId);
  int m_start_at_secs  @accessors(property=startAt);
  int m_end_at_secs    @accessors(property=endAt);
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementColorSupport addToClassOfObject:self];
    [PageElementFontSupport addToClassOfObject:self];
    [PageElementTextInputSupport addToClassOfObject:self];

    m_textTyped     = _json.text;
    m_start_at_secs = [check_for_undefined(_json.start_at_secs, "0") intValue];
    m_end_at_secs   = [check_for_undefined(_json.end_at_secs, "0") intValue];
    m_video_id      = check_for_undefined(_json.video_id, nil);
    [self setFontFromJson];
    [self setColorFromJson];
  }
  return self;
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !m_textTyped  ) {
    m_textTyped = "Enter Text Here";
  }

  if ( _mainView ) {
    [_mainView removeFromSuperview];
  }

  [self _setFont];
  [self setupMainViewAddTo:container];
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
