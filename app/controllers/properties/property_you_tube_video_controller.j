@implementation PropertyYouTubeVideoController : PropertyWindowController
{
  @outlet CPTextField m_artistName;
  @outlet CPTextField m_artistUrl;

  int m_original_value;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [m_artistUrl setStringValue:[m_pageElement artistUrl]];
  [m_artistName setStringValue:[m_pageElement artistName]];
  m_original_value = [m_pageElement searchEngines];
  var sb = [[_window contentView] subviews];
  var cnt = [sb count];
  for ( var idx = 0; idx < cnt; idx++ ) {
    if ( "CPCheckBox" == [sb[idx] class] ) {
      if ( (m_original_value & [[sb[idx] tag]]) > 0 ) {
        [sb[idx] setState:CPOnState];
      } else {
        [sb[idx] setState:CPOffState];
      }
    }
  }
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
  [m_pageElement setArtistName:[m_artistName stringValue]];
  [m_pageElement setArtistUrl:[m_artistUrl stringValue]];
  [m_pageElement updateServer];
  [_window close];
}

@end
