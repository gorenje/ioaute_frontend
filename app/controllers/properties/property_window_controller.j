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
@implementation PropertyWindowController : CPWindowController
{
  PageElement m_pageElement;
}

- (id)initWithWindowCibName:(CPString)cibName pageElement:(id)aPageElement
{
  self = [super initWithWindowCibName:cibName];
  if ( self ) {
    m_pageElement = aPageElement;
  }
  return self;
}

- (void)awakeFromCib
{
  [m_pageElement pushState];
  [[CPNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(windowWillClose:)
             name:CPWindowWillCloseNotification
           object:_window];
}

- (void) windowWillClose:(CPNotification)aNotification
{
  // some property windows open a color panel, close just in case.
  [[CPColorPanel sharedColorPanel] close];
}
  
- (CPAction)cancel:(id)sender
{
  [m_pageElement popState];
  [_window close];
}

- (void)setFocusOn:(CPView)aView
{
  [_window makeFirstResponder:aView];
}

// TODO could implement this BUT we need to captcha: 'cancel:', 'accept:' and the 
// TODO close button at the top-left of each window .... the 'x' at the top left
// TODO need to be removed via interface builder.
// - (void)runModal
// {
//   [self loadWindow];
//   [CPApp runModalForWindow:_window];
// }

@end
