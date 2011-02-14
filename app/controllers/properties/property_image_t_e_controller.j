@implementation PropertyImageTEController : PropertyWindowController
{
  @outlet CPTextField m_urlField;
  @outlet CPTextField m_linkField;
  @outlet CPTextField m_heightField;
  @outlet CPTextField m_widthField;
  @outlet CPTextField m_widthImageLabel;
  @outlet CPTextField m_heightImageLabel;

  @outlet CPView m_linksView;
  @outlet CPView m_sizeView;

  float m_orig_image_height;
  float m_orig_image_width;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [CPBox makeBorder:m_linksView];
  [CPBox makeBorder:m_sizeView];

  [m_heightField setStringValue:[CPString stringWithFormat:"%f", 
                                          [m_pageElement getSize].height]];
  [m_widthField setStringValue:[CPString stringWithFormat:"%f", 
                                         [m_pageElement getSize].width]];

  m_orig_image_height = [m_pageElement getImageSize].height;
  m_orig_image_width = [m_pageElement getImageSize].width;

  [m_widthImageLabel setStringValue:[CPString stringWithFormat:"%f", m_orig_image_width]];
  [m_heightImageLabel setStringValue:[CPString stringWithFormat:"%f", m_orig_image_height]];

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

- (CPAction)scaleWidth:(id)sender
{
  [m_widthField setStringValue:[CPString stringWithFormat:"%f", 
                                         m_orig_image_width * 
                                         (parseFloat([m_heightField stringValue]) / 
                                          m_orig_image_height)]]
}

- (CPAction)scaleHeight:(id)sender
{
  [m_heightField setStringValue:[CPString stringWithFormat:"%f", 
                                          m_orig_image_height * 
                                          (parseFloat([m_widthField stringValue]) / 
                                           m_orig_image_width)]]
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
