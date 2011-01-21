@implementation TextTE : ToolElement
{
  CPView _myContainer;
  CPString _textTyped;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    _textTyped = _json.text;
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
  _textView = [[LPMultiLineTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
  [_textView setFont:[CPFont systemFontOfSize:12.0]];
  [_textView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_textView setTextShadowColor:[CPColor whiteColor]];
  [_textView setDelegate:self];
  [_textView setScrollable:YES];
  [_textView setEditable:YES];
  [_textView setSelectable:YES];
  // TODO setPlaceholderString is not supported by LPMultiLineTextField
  //[_textView setPlaceholderString:@"Type Text"];
  [_textView setStringValue:@"Type Text Here"];

  _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView addSubview:_textView];

  [container addSubview:_mainView];
  if ( _textTyped ) {
    [_textView setStringValue:_textTyped];
  }
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolText];
}

@end

