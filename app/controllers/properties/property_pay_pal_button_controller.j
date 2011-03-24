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
@implementation PropertyPayPalButtonController : PropertyWindowController
{
  @outlet CPTextField   m_recipient;
  @outlet CPPopUpButton m_currency_list;

  @outlet CPButton      m_size_small;
  @outlet CPButton      m_size_large;
  @outlet CPButton      m_size_large_with_cc;

  @outlet CPView        m_settings_view;
  @outlet CPView        m_recipient_view;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [CPBox makeBorder:m_settings_view];
  [CPBox makeBorder:m_recipient_view];

  [m_recipient setStringValue:[m_pageElement recipient]];

  [m_currency_list removeAllItems];
  [m_currency_list addItemsWithTitles:["USD", "EUR", "YEN", "GBP"]];
  [m_currency_list selectItemWithTitle:[m_pageElement currency]];
  
  switch ( [m_pageElement imageSize] ) {
  case "small":
    [m_size_small setState:CPOnState];
    break;
  case "large":
    [m_size_large setState:CPOnState];
    break;
  case "large_with_cc":
    [m_size_large_with_cc setState:CPOnState];
    break;
  }
  [self setFocusOn:m_recipient];
}

- (CPAction)changeSize:(id)sender
{
  switch ( sender ) {
  case m_size_small:
    [m_pageElement setImageSize:"small"];
    break;
  case m_size_large:
    [m_pageElement setImageSize:"large"];
    break;
  case m_size_large_with_cc:
    [m_pageElement setImageSize:"large_with_cc"];
    break;
  }
}

- (CPAction)changeCurrency:(id)sender
{
  [m_pageElement setCurrency:[[sender selectedItem] title]];
}

- (CPAction)accept:(id)sender
{
  [_window close];
  [m_pageElement setRecipient:[m_recipient stringValue]];
  [m_pageElement updateServer];
}

@end
