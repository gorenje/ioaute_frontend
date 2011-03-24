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
@implementation PropertyTextTEController : PropertyWindowController
{
  @outlet CPTextField   m_fontSizeLabel;
  @outlet CPSlider      m_fontSizeSlider;
  @outlet CPColorWell   m_colorWell;
  @outlet CPPopUpButton m_fontNameButton;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [m_fontNameButton removeAllItems];
  [CPBox makeBorder:m_colorWell];

  var availableFonts = [[CPFontManager sharedFontManager] availableFonts];
  for(var idx = 0; idx < [availableFonts count]; idx++) {
    var font = [availableFonts objectAtIndex:idx];
    var menuItem = [[CPMenuItem alloc] initWithTitle:font action:NULL keyEquivalent:nil];
    [menuItem setFont:[CPFont fontWithName:font size:11.0]];
    [m_fontNameButton addItem:menuItem];
  }

  [m_fontNameButton selectItemWithTitle:[m_pageElement fontName]];
  [m_fontSizeSlider setDoubleValue:[m_pageElement fontSize]];
  [m_colorWell setColor:[m_pageElement getColor]];

  [m_fontSizeLabel setStringValue:[CPString stringWithFormat:"%0.2f", 
                                            [m_fontSizeSlider doubleValue]]];
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
  [m_pageElement setTextColor:[m_colorWell color]];
}

- (CPAction)accept:(id)sender
{
  [m_pageElement updateServer];
  [_window close];
}

@end
