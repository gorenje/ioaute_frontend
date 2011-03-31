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
@implementation PropertyImageTEController : PropertyWindowController
{
  @outlet CPTextField m_urlField;
  @outlet CPTextField m_linkField;
  @outlet CPTextField m_heightField;
  @outlet CPTextField m_widthField;
  @outlet CPTextField m_widthImageLabel;
  @outlet CPTextField m_heightImageLabel;
  @outlet CPTextField m_reloadIntervalValue;

  @outlet CPSlider m_reloadSlider;
  @outlet CPButton m_reloadButton;

  @outlet CPView m_linksView;
  @outlet CPView m_sizeView;
  @outlet CPView m_reloadView;
  @outlet CPView m_intervalScrollView;

  float m_orig_image_height;
  float m_orig_image_width;
}

- (void)includeMixins
{
  [PropertyControllerRotationSupport addToClassOfObject:self];
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [CPBox makeBorder:m_linksView];
  [CPBox makeBorder:m_sizeView];
  [CPBox makeBorder:m_reloadView];

  [m_heightField setStringValue:[CPString stringWithFormat:"%f", 
                                          [m_pageElement getSize].height]];
  [m_widthField setStringValue:[CPString stringWithFormat:"%f", 
                                         [m_pageElement getSize].width]];

  m_orig_image_height = [m_pageElement getImageSize].height;
  m_orig_image_width = [m_pageElement getImageSize].width;

  [m_widthImageLabel setStringValue:[CPString stringWithFormat:"%f", m_orig_image_width]];
  [m_heightImageLabel setStringValue:[CPString stringWithFormat:"%f", m_orig_image_height]];

  [m_urlField setStringValue:[m_pageElement imageUrl]];
  [m_linkField setStringValue:[m_pageElement linkUrl]];

  var reloadInterval = [m_pageElement reloadInterval];
  if ( reloadInterval > 0 ) {
    [m_reloadButton setState:CPOnState];
    [m_intervalScrollView setHidden:NO];
  } else {
    [m_reloadButton setState:CPOffState];
    [m_intervalScrollView setHidden:YES];
  }

  [m_reloadSlider setValue:[m_pageElement reloadInterval]];
  [self updateReloadIntervalScroller];

  [self setFocusOn:m_widthField];
  [self awakeFromCibSetupRotationFields:m_pageElement];
}

- (CPAction)setReloadInterval:(id)sender
{
  [self updateReloadIntervalScroller];
}

- (CPAction)reloadButtonPressed:(id)sender
{
  if ( [m_reloadButton state] == CPOnState) {
    [m_intervalScrollView setHidden:NO];
    [self updateReloadIntervalScroller];
  } else {
    [m_intervalScrollView setHidden:YES];
    [m_pageElement setReloadInterval:0];
    [m_reloadSlider setValue:[m_pageElement reloadInterval]];
    [self updateReloadIntervalScroller];
  }
}

- (CPAction)setSizeToOriginal:(id)sender
{
  [m_heightField setStringValue:[CPString stringWithFormat:"%f", 
                                          [m_pageElement getImageSize].height]];
  [m_widthField setStringValue:[CPString stringWithFormat:"%f", 
                                         [m_pageElement getImageSize].width]];
  [self updateFrameSize];
}

- (CPAction)scaleWidth:(id)sender
{
  [m_widthField setStringValue:[CPString stringWithFormat:"%f", 
                                         m_orig_image_width * 
                                         ([m_heightField doubleValue] / 
                                          m_orig_image_height)]];
  [self updateFrameSize];
}

- (CPAction)scaleHeight:(id)sender
{
  [m_heightField setStringValue:[CPString stringWithFormat:"%f", 
                                          m_orig_image_height * 
                                          ([m_widthField doubleValue] / 
                                           m_orig_image_width)]];
  [self updateFrameSize];
}

- (CPAction)accept:(id)sender
{
  [_window close];
  [m_pageElement setReloadInterval:[m_reloadSlider intValue]];
  [m_pageElement setLinkUrl:[m_linkField stringValue]];
  [m_pageElement setImageUrl:[m_urlField stringValue]];

  [self updateFrameSize];
  [m_pageElement setRotation:[m_rotationSlider intValue]];

  [m_pageElement updateServer];
  [m_pageElement sendResizeToServer];
}

//
// Helpers
//
- (void) updateReloadIntervalScroller
{
  var str = [CPString stringWithFormat:"%d mins", [m_reloadSlider intValue]];
  [m_reloadIntervalValue setStringValue:str];
}

- (void)updateFrameSize
{
  var sizeVal = CGSizeMake( [m_widthField doubleValue], [m_heightField doubleValue] );
  [m_pageElement setFrameSize:sizeVal];
}

@end
