@implementation PropertyImageTEController : PropertyWindowController
{
  @outlet CPTextField m_urlField;
  @outlet CPTextField m_linkField;
  @outlet CPTextField m_heightField;
  @outlet CPTextField m_widthField;
  @outlet CPTextField m_widthImageLabel;
  @outlet CPTextField m_heightImageLabel;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [m_heightField setStringValue:[CPString stringWithFormat:"%f", 
                                          [m_pageElement getSize].height]];
  [m_widthField setStringValue:[CPString stringWithFormat:"%f", 
                                         [m_pageElement getSize].width]];

  [m_widthImageLabel setStringValue:[CPString stringWithFormat:"%f", 
                                              [m_pageElement getImageSize].width]];
  [m_heightImageLabel setStringValue:[CPString stringWithFormat:"%f", 
                                               [m_pageElement getImageSize].height]];

  [m_urlField setStringValue:[m_pageElement getImageUrl]];
  [m_linkField setStringValue:[m_pageElement getLinkUrl]];
}

- (CPAction)setSizeToOriginal:(id)sender
{
  [m_heightField setStringValue:[CPString stringWithFormat:"%f", 
                                          [m_pageElement getImageSize].height]];
  [m_widthField setStringValue:[CPString stringWithFormat:"%f", 
                                         [m_pageElement getImageSize].width]];
  
}

- (CPAction)accept:(id)sender
{
  [m_pageElement setImageUrl:[m_urlField stringValue]];
  [m_pageElement setLinkUrl:[m_linkField stringValue]];
  var sizeVal = CGSizeMake( parseFloat([m_widthField stringValue]),
                            parseFloat([m_heightField stringValue]) );
  [m_pageElement setFrameSize:sizeVal];

  [m_pageElement updateServer];
  [m_pageElement sendResizeToServer];
  [_window close];
}

@end
