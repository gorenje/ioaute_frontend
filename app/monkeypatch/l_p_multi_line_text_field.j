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
  Mainly for text fields that enjoy taking the left mouse as they own and thereby
  not notifying the DocumentViewEditorView of focus.
*/
@implementation LPMultiLineTextField (RightMouseSupport)

- (void)rightMouseDown:(CPEvent)anEvent
{
  [[DocumentViewEditorView sharedInstance] focusOnDocumentViewCell:[self superview]];
}

// TODO use the right mouse to move text page elements but all the following is not
// TODO working since the event is not arriving here.
// See CPWindow.j for the event handling mechanism.
//
// - (void)rightMouseDragged:(CPEvent)anEvent
// {
//   CPLogConsole( "RIGHT Mouse Bragged" );
// }
// - (void)mouseDragged:(CPEvent)anEvent
// {
//   CPLogConsole( "Mouse Bragged" );
//   if ( [anEvent type] == CPRightMouseDragged ) {
//     CPLogConsole( "right mouse drtagger" );
//   } else {
//     return [[[anEvent window] platformWindow] _propagateCurrentDOMEvent:YES];
//   }
// }

@end
