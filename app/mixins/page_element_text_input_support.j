/*!
  Mixin for creating and managing a text field input. It assumes that there is 
  a _mainView CPView to use to define the CPTextField.

  Further it assumes that [self font] returns the current CPFont object and
  [self getColor] returns the current text color. Also [self textTyped] will
  return the current text to display and [self setTextTyped] will update the
  current text.

  Further still, [self updateServer] will send any text update to the server.
*/
@implementation PageElementTextInputSupport : MixinHelper 

/*!
  Assume that we have font and color support also mixed in.
*/
- (void)setupMainViewAddTo:(CPView)aContainer
{
  _mainView = [[LPMultiLineTextField alloc] 
                initWithFrame:CGRectInset([aContainer bounds], 4, 4)];
  [_mainView setFont:[self font]];
  [_mainView setTextColor:[self getColor]];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setDelegate:self];
  [_mainView setScrollable:YES];
  [_mainView setEditable:YES];
  [_mainView setSelectable:YES];

  [_mainView setStringValue:[self textTyped]];
  [aContainer addSubview:_mainView];
}

/*
  Delegate methods from the text field.
*/
- (void)checkForChangedText:(CPString)aNewText
{
  if ( [self textTyped] !== aNewText ) {
    [self setTextTyped:aNewText];
    [self updateServer];
  }
}

/*! 
  Notifications recieved from the text field
*/
- (void)controlTextDidBeginEditing:(id)aNotification
{
  [[DocumentViewEditorView sharedInstance] setDocumentViewCell:[_mainView superview]];
}

- (void)controlTextDidChange:(id)aNotification
{
  [self checkForChangedText:[[aNotification object] stringValue]];
}

- (void)controlTextDidEndEditing:(id)aNotification
{
  [self checkForChangedText:[[aNotification object] stringValue]];
}

- (void)controlTextDidFocus:(id)aNotification
{
  [[_mainView superview] setSelected:YES];
  [[DocumentViewEditorView sharedInstance] setDocumentViewCell:[_mainView superview]];
}

- (void)controlTextDidBlur:(id)aNotification
{
  [self checkForChangedText:[[aNotification object] stringValue]];
}

@end
