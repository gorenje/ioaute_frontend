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
@implementation PropertyYouTubeSeekToLinkTEController : PropertyWindowController
{
  @outlet CPColorWell m_colorWell;
  @outlet CPTextField m_linkTitle;

  @outlet CPTextField   m_fontSizeLabel;
  @outlet CPPopUpButton m_fontNameButton;
  @outlet CPSlider      m_fontSizeSlider;

  @outlet CPView m_fontView;
  @outlet CPView m_videoInfoView;
  @outlet CPView m_endAtView;

  @outlet CPButton m_setEndAt;
  @outlet CPPopUpButton m_videoDropdown;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [SeekToDropdownHelpers addToClassOfObject:self];
  [CPBox makeBorder:m_fontView];
  [CPBox makeBorder:m_videoInfoView];
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

  [m_linkTitle setStringValue:[m_pageElement textTyped]];
  [m_colorWell setColor:[m_pageElement getColor]];

  [m_fontSizeLabel setStringValue:[CPString stringWithFormat:"%0.2f", 
                                            [m_fontSizeSlider doubleValue]]];

  // video drop down needs to be filled and correct item needs selecting
  [m_videoDropdown removeAllItems];
  var menuItem = [CPMenuItem withTitle:"None Set" andTag:0];
  [m_videoDropdown addItem:menuItem];

  var allYouTubeVideos = [[DocumentViewController sharedInstance] 
                           allPageElementsOfType:YouTubeVideo
                                          orType:YouTubeTE];
  for ( var idx = 0; idx < [allYouTubeVideos count]; idx++ ) {
    var youTubeVideo = allYouTubeVideos[idx];
    var menuItem = [CPMenuItem withTitle:[youTubeVideo videoTitle]
                                  andTag:[youTubeVideo videoId]];
    [m_videoDropdown addItem:menuItem];
  }
  [m_videoDropdown selectItemWithTag:[[m_pageElement videoId] intValue]];

  // start at values
  var popUps = [self obtainStartAtPopUps:[m_videoInfoView subviews]];
  [self setSeekToPopUpValues:popUps];
  [self setPopUpsWithTime:[m_pageElement startAt] popUps:popUps];

  // end at values
  if ( [m_pageElement endAt] > 0 ) {
    [m_setEndAt setState:CPOnState];
    [m_endAtView setHidden:NO];
  } else {
    [m_setEndAt setState:CPOffState];
    [m_endAtView setHidden:YES];
  }
  var popUps = [self obtainEndAtPopUps:[m_endAtView subviews]];
  [self setSeekToPopUpValues:popUps];
  [self setPopUpsWithTime:[m_pageElement endAt] popUps:popUps];
  [self setFocusOn:m_linkTitle];
}

- (CPAction)endAtToggled:(id)sender
{
  switch ( [m_setEndAt state] ) {
  case CPOffState: [m_endAtView setHidden:YES]; break;
  case CPOnState:  
    [m_endAtView setHidden:NO];
    var startPopUps = [self obtainStartAtPopUps:[m_videoInfoView subviews]];
    var endPopUps = [self obtainEndAtPopUps:[m_endAtView subviews]];
    for ( var idx = 0; idx < 3; idx++ ) {
      [endPopUps[idx] selectItemWithTitle:[[startPopUps[idx] selectedItem] title]];
    }
    break;
  }
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
  [_window close];
  switch ( [m_setEndAt state] ) {
  case CPOffState: [m_pageElement setEndAt:0];  break;
  case CPOnState:
    [m_pageElement 
      setEndAt:[self obtainSeconds:[self obtainEndAtPopUps:[m_endAtView subviews]]]];
    break;
  }
  [m_pageElement 
      setStartAt:[self obtainSeconds:[self obtainStartAtPopUps:[m_videoInfoView subviews]]]];
  [m_pageElement setVideoId:[CPString stringWithFormat:"%d", 
                                      [[m_videoDropdown selectedItem] tag]]];
  [m_pageElement setLinkText:[m_linkTitle stringValue]];

  [m_pageElement updateServer];
}

//
// Helpers
//

- (CPArray)obtainStartAtPopUps:(CPArray)subviewsToCheck
{
  return [self findPopUpsWithTags:[1,2,4] inViews:subviewsToCheck];
}

- (CPArray)obtainEndAtPopUps:(CPArray)subviewsToCheck
{
  return [self findPopUpsWithTags:[8,16,32] inViews:subviewsToCheck];
}

@end
