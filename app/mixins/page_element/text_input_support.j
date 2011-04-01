/*
 * Created by Gerrit Riessen
 * Copyright 2010-2011, Gerrit Riessen
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*!
  Mixin for creating and managing a text field input. It assumes that there is 
  a _mainView CPView to use to define the CPTextField.

  Further it assumes that [self font] returns the current CPFont object and
  [self getColor] returns the current text color. Also [self textTyped] will
  return the current text to display and [self setTextTyped] will update the
  current text.

  Further still, [self updateServer] will send any text update to the server.
*/
@implementation PageElementTextInputSupport : GRClassMixin

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
  [_mainView setTextAlignment:[self textAlignment]];

  [_mainView setStringValue:[self textTyped]];

  /* 
     This does not yet work because the last line bombs with editor[null] is not an expression
     or something ... so stick with the lp multi line for now.

  _mainView = [[WKTextView alloc] initWithFrame:CGRectInset([aContainer bounds], 4, 4)];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setAutohidesScrollers:YES];
  [_mainView setShouldFocusAfterAction:YES];
  [_mainView setBackgroundColor:[CPColor transparent]];
  [_mainView setDelegate:self];
  // [_mainView setScrollable:YES];
  [_mainView setEditable:YES];
  // [_mainView setSelectable:YES];
  [_mainView setFontNameForSelection:[[self font] familyName]];
  */
  [aContainer addSubview:_mainView];
}

/*! 
  Revert the text input box to the new font and text and color.
*/
- (void)revertTextAttributes
{
  [_mainView setStringValue:[self textTyped]];
  [_mainView setFont:[self font]];
  [_mainView setTextColor:[self getColor]];
  [_mainView setTextAlignment:[self textAlignment]];
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
