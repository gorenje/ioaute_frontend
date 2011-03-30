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
  @outlet CPColorWell        m_colorWell;
}

- (void)includeMixins
{
  [PropertyControllerFontSupport addToClassOfObject:self];
}

- (void)awakeFromCib
{
  [super awakeFromCib];

  [CPBox makeBorder:m_colorWell];
  [m_colorWell setColor:[m_pageElement getColor]];

  [self awakeFromCibSetupFontFields:m_pageElement];
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
