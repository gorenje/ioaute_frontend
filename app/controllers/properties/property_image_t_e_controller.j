@implementation PropertyImageTEController : PropertyWindowController
{
  @outlet CPTextField m_urlField;
  @outlet CPTextField m_linkField;
  @outlet CPTextField m_heightField;
  @outlet CPTextField m_widthField;
  @outlet CPTextField m_widthImageLabel;
  @outlet CPTextField m_heightImageLabel;
  @outlet CPTextField m_reloadIntervalValue;
  @outlet CPTextField m_rotationValue;

  @outlet CPSlider m_reloadSlider;
  @outlet CPButton m_reloadButton;
  @outlet CPSlider m_rotationSlider;

  @outlet CPView m_linksView;
  @outlet CPView m_sizeView;
  @outlet CPView m_reloadView;
  @outlet CPView m_intervalScrollView;
  @outlet CPView m_rotationView;

  CPString m_orig_image_url;
  float m_orig_image_height;
  float m_orig_image_width;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [CPBox makeBorder:m_linksView];
  [CPBox makeBorder:m_sizeView];
  [CPBox makeBorder:m_reloadView];
  [CPBox makeBorder:m_rotationView];

  [m_heightField setStringValue:[CPString stringWithFormat:"%f", 
                                          [m_pageElement getSize].height]];
  [m_widthField setStringValue:[CPString stringWithFormat:"%f", 
                                         [m_pageElement getSize].width]];

  m_orig_image_height = [m_pageElement getImageSize].height;
  m_orig_image_width = [m_pageElement getImageSize].width;

  [m_widthImageLabel setStringValue:[CPString stringWithFormat:"%f", m_orig_image_width]];
  [m_heightImageLabel setStringValue:[CPString stringWithFormat:"%f", m_orig_image_height]];

  m_orig_image_url = [m_pageElement imageUrl];
  [m_urlField setStringValue:m_orig_image_url];
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

  [m_rotationSlider setValue:[m_pageElement rotation]];
  [self updateRotationValue];
  [_window makeFirstResponder:m_widthField];
}

- (CPAction)setRotationValue:(id)sender
{
  [m_rotationSlider setValue:[m_rotationValue intValue]];
  [self updateRotationValue];
}

- (CPAction)setRotation:(id)sender
{
  [self updateRotationValue];
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
}

- (CPAction)scaleWidth:(id)sender
{
  [m_widthField setStringValue:[CPString stringWithFormat:"%f", 
                                         m_orig_image_width * 
                                         ([m_heightField doubleValue] / 
                                          m_orig_image_height)]];
}

- (CPAction)scaleHeight:(id)sender
{
  [m_heightField setStringValue:[CPString stringWithFormat:"%f", 
                                          m_orig_image_height * 
                                          ([m_widthField doubleValue] / 
                                           m_orig_image_width)]];
}

- (CPAction)accept:(id)sender
{
  [m_pageElement setReloadInterval:[m_reloadSlider intValue]];
  [m_pageElement setLinkUrl:[m_linkField stringValue]];
  var sizeVal = CGSizeMake( [m_widthField doubleValue], [m_heightField doubleValue] );
  [m_pageElement setFrameSize:sizeVal];

  if ( m_orig_image_url != [m_urlField stringValue] ) {
    [m_pageElement setImageUrl:[m_urlField stringValue]];
  }
  [m_pageElement setRotation:[m_rotationSlider intValue]];

  [m_pageElement updateServer];
  [m_pageElement sendResizeToServer];
  [_window close];
}

//
// Helpers
//
- (void) updateReloadIntervalScroller
{
  var str = [CPString stringWithFormat:"%d mins", [m_reloadSlider intValue]];
  [m_reloadIntervalValue setStringValue:str];
}

- (void) updateRotationValue
{
  var value = [[m_rotationSlider stringValue] intValue];
  var str = [CPString stringWithFormat:"%d", value];
  [m_rotationValue setStringValue:str];
  [m_pageElement setRotation:value];
}

@end
