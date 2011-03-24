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
@implementation PromptWindowController : CPWindowController
{
  @outlet CPTextField m_inputField;
  @outlet CPTextField m_label;
  @outlet CPView      m_borderView;

  CPString m_prompt       @accessors(property=prompt);
  CPString m_defaultValue @accessors(property=defaultValue);
  id       m_delegate     @accessors(property=delegate);
  SEL      m_selector     @accessors(property=selector);
}

- (void)runModal
{
  [self loadWindow];
  [m_label setStringValue:m_prompt];
  [_window makeFirstResponder:m_inputField];
  [CPApp runModalForWindow:_window];
}

- (void)awakeFromCib
{
  [CPBox makeBorder:m_borderView];
}

- (CPAction)accept:(id)sender
{
  [_window close];
  [CPApp abortModal];
  var value = [[m_inputField stringValue] stringByTrimmingWhitespace];
  [m_delegate performSelector:m_selector
                   withObject:([value isBlank] ? m_defaultValue : value)];
}

- (CPAction)cancel:(id)sender
{
  [_window close];
  [CPApp abortModal];
  [m_delegate performSelector:m_selector withObject:m_defaultValue];
}

@end
