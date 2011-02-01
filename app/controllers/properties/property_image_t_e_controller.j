@implementation PropertyImageTEController : PropertyWindowController
{
  @outlet CPTextField m_urlField;
  @outlet CPTextField m_linkField;
}

- (void)awakeFromCib
{
  [m_urlField setStringValue:[m_pageElement getImageUrl]];
  [m_linkField setStringValue:[m_pageElement getLinkUrl]];
}

- (CPAction)accept:(id)sender
{
  [m_pageElement setImageUrl:[m_urlField stringValue]];
  [m_pageElement setLinkUrl:[m_linkField stringValue]];
  [m_pageElement updateServer];
  [_window close];
}

@end
