@implementation PropertyYouTubeVideoController : PropertyWindowController
{
  @outlet CPTextField m_artistName;
  @outlet CPTextField m_artistUrl;
  @outlet CPTextField m_videoLink;
  @outlet CPView m_artistView;
  @outlet CPView m_linkAndTitleView;
  @outlet CPView m_searchLinksView;
  @outlet CPView m_playerCtrlView;
  @outlet CPView m_rotationView;

  @outlet CPSlider m_rotationSlider;
  @outlet CPTextField m_rotationValue;
  @outlet CPTextField m_seekToField;
  @outlet CPTextField m_videoIdField;

  int m_original_value;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
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

  [m_seekToField setStringValue:[m_pageElement seekTo]];

  [m_rotationSlider setValue:[m_pageElement rotation]];
  [self updateRotationValue];

  var str = [CPString stringWithFormat:"(ID: %d)", [m_pageElement videoId]];
  [m_videoIdField setStringValue:str];
}

- (void)checkCheckBoxes:(CPArray)subviewsToCheck
{
  var cnt = [subviewsToCheck count];
  for ( var idx = 0; idx < cnt; idx++ ) {
    if ( "CPCheckBox" == [subviewsToCheck[idx] class] ) {
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
  [m_rotationSlider setValue:parseInt([m_rotationValue stringValue])];
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
  } else {
    [m_pageElement addSearchEngine:[sender tag]];
  }
}

- (CPAction)cancel:(id)sender
{
  [super cancel:sender];
  [m_pageElement setSearchEngines:m_original_value];
}

- (CPAction)accept:(id)sender
{
  [m_pageElement setSeekTo:parseInt([m_seekToField stringValue])];
  [m_pageElement setRotation:parseInt([m_rotationSlider doubleValue])];
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
  var str = [CPString stringWithFormat:"%d", 
                      parseInt([m_rotationSlider doubleValue])];
  [m_pageElement setRotation:parseInt([m_rotationSlider doubleValue])];
  [m_rotationValue setStringValue:str];
}

@end
