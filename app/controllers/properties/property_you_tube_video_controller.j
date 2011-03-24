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
@implementation PropertyYouTubeVideoController : PropertyWindowController
{
  @outlet CPTextField m_artistName;
  @outlet CPTextField m_artistUrl;
  @outlet CPTextField m_videoLink;
  @outlet CPTextField m_rotationValue;
  @outlet CPTextField m_videoIdField;

  @outlet CPView m_artistView;
  @outlet CPView m_linkAndTitleView;
  @outlet CPView m_searchLinksView;
  @outlet CPView m_playerCtrlView;
  @outlet CPView m_rotationView;
  @outlet CPView m_cueVideoView;

  @outlet CPSlider m_rotationSlider;

  int m_original_value;
  int m_original_rotation;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [SeekToDropdownHelpers addToClassOfObject:self];
  [CPBox makeBorder:m_artistView];
  [CPBox makeBorder:m_linkAndTitleView];
  [CPBox makeBorder:m_searchLinksView];
  [CPBox makeBorder:m_playerCtrlView];
  [CPBox makeBorder:m_rotationView];

  [m_artistUrl setStringValue:[m_pageElement artistUrl]];
  [m_artistName setStringValue:[m_pageElement artistName]];

  m_original_value = [m_pageElement searchEngines];
  [self checkCheckBoxes:[m_searchLinksView subviews]];
  [self checkCheckBoxes:[m_linkAndTitleView subviews]];
  [self checkCheckBoxes:[m_playerCtrlView subviews]];

  [m_videoLink setStringValue:[m_pageElement videoLink]];
  [m_videoLink setSelectable:YES];
  [m_videoLink setEditable:YES];

  if ( (m_original_value & 256) > 0 ) {
    [m_cueVideoView setHidden:NO];
  } else {
    [m_cueVideoView setHidden:YES];
  }
  var popUps = [self findPopUpsWithTags:[1,2,4] inViews:[m_cueVideoView subviews]];
  [self setSeekToPopUpValues:popUps];
  [self setPopUpsWithTime:[m_pageElement seekTo] popUps:popUps];

  m_original_rotation = [m_pageElement rotation];
  [m_rotationSlider setValue:[m_pageElement rotation]];
  [self updateRotationValue];

  var str = [CPString stringWithFormat:"(ID: %d)", [m_pageElement videoId]];
  [m_videoIdField setStringValue:str];
  [m_videoIdField setHidden:YES];
}

- (void)checkCheckBoxes:(CPArray)subviewsToCheck
{
  var cnt = [subviewsToCheck count];
  for ( var idx = 0; idx < cnt; idx++ ) {
    if ( [subviewsToCheck[idx] isKindOfClass:CPCheckBox] ) {
      if ( (m_original_value & [[subviewsToCheck[idx] tag]]) > 0 ) {
        [subviewsToCheck[idx] setState:CPOnState];
      } else {
        [subviewsToCheck[idx] setState:CPOffState];
      }
    }
  }
}

- (CPAction)setRotationValue:(id)sender
{
  [m_rotationSlider setValue:[m_rotationValue intValue]];
  [self updateRotationValue];
}

- (CPAction)setRotationFromSlider:(id)sender
{
  [self updateRotationValue];
}

- (CPAction)searchButton:(id)sender
{
  if ( [sender state] == CPOffState ) {
    [m_pageElement removeSearchEngine:[sender tag]];
    if ( [sender tag] == 256 ) [m_cueVideoView setHidden:YES];
  } else {
    [m_pageElement addSearchEngine:[sender tag]];
    if ( [sender tag] == 256 ) [m_cueVideoView setHidden:NO];
  }
}

- (CPAction)cancel:(id)sender
{
  [super cancel:sender];
  [m_pageElement setSearchEngines:m_original_value];
  [m_pageElement setRotation:m_original_rotation];
}

- (CPAction)accept:(id)sender
{
  if ( ([m_pageElement searchEngines] & 256) > 0 ) {
    var popUps = [self findPopUpsWithTags:[1,2,4] inViews:[m_cueVideoView subviews]];
    [m_pageElement setSeekTo:[self obtainSeconds:popUps]];
  } else {
    [m_pageElement setSeekTo:0];
  }
  [m_pageElement setRotation:[m_rotationSlider intValue]];
  [m_pageElement setArtistName:[m_artistName stringValue]];
  [m_pageElement setArtistUrl:[m_artistUrl stringValue]];
  [m_pageElement updateServer];
  [_window close];
}

//
// Helpers
//
- (void) updateRotationValue
{
  var str = [CPString stringWithFormat:"%d", [m_rotationSlider intValue]];
  [m_pageElement setRotation:[m_rotationSlider intValue]];
  [m_rotationValue setStringValue:str];
}

@end
