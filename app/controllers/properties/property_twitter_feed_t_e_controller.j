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
@implementation PropertyTwitterFeedTEController : PropertyWindowController
{
  @outlet CPTextField m_forUserField;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [m_forUserField setStringValue:[m_pageElement getForUser]];
  [self setFocusOn:m_forUserField];
}

- (CPAction)accept:(id)sender
{
  [m_pageElement setForUser:[m_forUserField stringValue]];
  [m_pageElement updateServer];
  [_window close];
}

@end
