@implementation TextTE : ToolElement
{
  CPView _myContainer;
  CPString _textTyped;

  float m_fontSize;
  CPString m_fontName;

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
    _textTyped = _json.text;
    [self setFontFromJson];
    [self setColorFromJson];
  }
  return self;
}

// - (void) controlTextDidBeginEditing:(id)sender
// {
// }

// - (void) controlTextDidChange:(id)sender
// {
// }

- (void) controlTextDidEndEditing:(id)sender
{
  _textTyped = [[sender object] stringValue];
  [self updateServer]; // this sends _textTyped to the server, hence we set it first.
}

- (void) controlTextDidFocus:(id)sender
{
  [_myContainer setSelected:YES];
}

// - (void) controlTextDidBlur:(id)sender
// {
// }

- (void)generateViewForDocument:(CPView)container
{
  if ( !_myContainer ) _myContainer = container;

  if ( _mainView) {
    [_mainView removeFromSuperview];
  }

  _mainView = [[LPMultiLineTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
  [_mainView setFont:[CPFont systemFontOfSize:12.0]];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setTextShadowColor:[CPColor whiteColor]];
  [_mainView setDelegate:self];
  [_mainView setScrollable:YES];
  [_mainView setEditable:YES];
  [_mainView setSelectable:YES];
  // TODO setPlaceholderString is not supported by LPMultiLineTextField
  //[_mainView setPlaceholderString:@"Type Text"];
  [_mainView setStringValue:@"Type Text Here"];

  [container addSubview:_mainView];
  if ( _textTyped ) {
    [_mainView setStringValue:_textTyped];
  }
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolText];
}

@end

@implementation TextTE (PropertyHandling)

- (BOOL) hasProperties
{
  return YES;
}

- (void)openProperyWindow
{
  [[[PropertyTextTEController alloc] initWithWindowCibName:TextTEPropertyWindowCIB 
                                               pageElement:self] showWindow:self];
}

- (void)setTextColor:(CPColor)aColor
{
  [self setColor:aColor];
  [_mainView setTextColor:aColor];
}

@end
