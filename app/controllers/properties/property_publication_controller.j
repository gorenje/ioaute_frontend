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
@implementation PropertyPublicationController : CPWindowController
{
  @outlet CPTextField m_snapgridField;
  @outlet CPTextField m_titleField;
  @outlet CPSlider    m_snapgridSlider;
  @outlet CPView      m_snapgridView;
  @outlet CPButton    m_continousFlow;
  @outlet CPButton    m_pageShadow;
  @outlet CPColorWell m_colorWell;
  @outlet CPView      m_publicationDetailsView;
  @outlet CPView      m_titleView;
  @outlet CPButton    m_toolTips;

  PubConfig m_pubConfig;
}

- (void)awakeFromCib
{
  [CPBox makeBorder:m_snapgridView];
  [CPBox makeBorder:m_publicationDetailsView];
  [CPBox makeBorder:m_colorWell];
  [CPBox makeBorder:m_titleView];

  m_pubConfig = [[ConfigurationManager sharedInstance] pubProperties];
  [m_pubConfig pushState];

  [m_colorWell setColor:[m_pubConfig getColor]];
  [m_continousFlow setState:([m_pubConfig isContinous] ? CPOnState : CPOffState)];
  [m_pageShadow setState:([m_pubConfig hasShadow] ? CPOnState : CPOffState)];
  [m_snapgridSlider setValue:[m_pubConfig snapGridWidth]];
  [m_titleField setStringValue:[m_pubConfig pubName]];
  
  [m_toolTips setState:( [m_pubConfig showToolTips] ? CPOffState : CPOnState )];
  [self updateSnapgridValue];
  [_window makeFirstResponder:m_titleField];

  [[CPNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(windowWillClose:)
             name:CPWindowWillCloseNotification
           object:_window];
}

- (void) windowWillClose:(CPNotification)aNotification
{
  [[CPColorPanel sharedColorPanel] close];
}

- (CPAction)toggleToolTips:(id)sender
{
  [m_pubConfig setShowToolTips:([m_toolTips state] == CPOffState)];
}

- (CPAction)colorChanged:(id)sender
{
  [m_pubConfig setBgColor:[m_colorWell color]];
}

- (CPAction)setSnapgrid:(id)sender
{
  [self updateSnapgridValue];
}

- (CPAction)setSnapgridValue:(id)sender
{
  [m_snapgridSlider setValue:[m_snapgridField intValue]];
  [self updateSnapgridValue];
}

- (CPAction)setShadowValue:(id)sender
{
  [m_pubConfig setShadow:([sender state] == CPOnState ? "1" : "0")];
}

- (CPAction)cancel:(id)sender
{
  [_window close];
  [m_pubConfig popState];
}

- (CPAction)accept:(id)sender
{
  [_window close];
  [m_pubConfig setPubName:[m_titleField stringValue]];
  [m_pubConfig setContinous:([m_continousFlow state] == CPOnState ? "1" : "0")];
  [[CommunicationManager sharedInstance] publicationUpdate:m_pubConfig];
}

//
// Helpers
//
- (void) updateSnapgridValue
{
  [m_snapgridField 
    setStringValue:[CPString 
                     stringWithFormat:"%d", [m_snapgridSlider intValue]]];
  [m_pubConfig setSnapGridWidth:[m_snapgridSlider intValue]];
}

@end
