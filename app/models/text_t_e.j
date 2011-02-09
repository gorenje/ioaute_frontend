@implementation TextTE : ToolElement
{
  CPView _myContainer;
  CPString _textTyped;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementColorSupport addToClass:[self class]];
    [PageElementFontSupport addToClass:[self class]];
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
  // TODO setPlaceholderString is not supported by LPMultiLineTextField
  //[_mainView setPlaceholderString:@"Type Text"];

  [container addSubview:_mainView];
  if ( _textTyped ) {
    [_mainView setStringValue:_textTyped];
  } else {
    [_mainView setStringValue:@"Type Text Here"];
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
