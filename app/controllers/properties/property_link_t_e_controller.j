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
@implementation PropertyLinkTEController : PropertyWindowController
{
  @outlet CPColorWell m_colorWell;
  @outlet CPTextField m_linkDestination;
  @outlet CPTextField m_linkTitle;

  @outlet CPTextField   m_fontSizeLabel;
  @outlet CPSlider      m_fontSizeSlider;
  @outlet CPPopUpButton m_fontNameButton;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [CPBox makeBorder:m_colorWell];

  [m_fontNameButton removeAllItems];
  var availableFonts = [[CPFontManager sharedFontManager] availableFonts];
  for(var idx = 0; idx < [availableFonts count]; idx++) {
    var font = [availableFonts objectAtIndex:idx];
    var menuItem = [[CPMenuItem alloc] initWithTitle:font action:NULL keyEquivalent:nil];
    [menuItem setFont:[CPFont fontWithName:font size:11.0]];
    [m_fontNameButton addItem:menuItem];
  }

  [m_fontNameButton selectItemWithTitle:[m_pageElement fontName]];
  [m_fontSizeSlider setDoubleValue:[m_pageElement fontSize]];

  [m_linkTitle setStringValue:[m_pageElement getLinkTitle]];
  [m_linkDestination setStringValue:[m_pageElement getDestination]];
  [m_colorWell setColor:[m_pageElement getColor]];

  [m_fontSizeLabel setStringValue:[CPString stringWithFormat:"%0.2f", 
                                            [m_fontSizeSlider doubleValue]]];
  [self setFocusOn:m_linkDestination];
}

- (CPAction)fontNameSelected:(id)sender
{
  [m_pageElement setFontName:[[m_fontNameButton selectedItem] title]];
}

- (CPAction)fontSizeSliderAction:(id)sender
{
  [m_fontSizeLabel setStringValue:[CPString stringWithFormat:"%0.2f", 
                                            [m_fontSizeSlider doubleValue]]];
  [m_pageElement setFontSize:[m_fontSizeSlider doubleValue]];
}

- (CPAction)updateColor:(id)sender
{
  [m_pageElement setLinkColor:[m_colorWell color]];
}

- (CPAction)accept:(id)sender
{
  [_window close];
  [m_pageElement setLinkTitle:[m_linkTitle stringValue]];
  [m_pageElement setLinkDestination:[m_linkDestination stringValue]];
  [m_pageElement updateServer];
}

@end
