@implementation PropertyLinkTEController : PropertyWindowController
{
  @outlet CPColorWell m_colorWell;
  @outlet CPTextField m_linkDestination;
  @outlet CPTextField m_linkTitle;
}

- (void)awakeFromCib
{
  [m_linkTitle setStringValue:[m_pageElement getLinkTitle]];
  [m_linkDestination setStringValue:[m_pageElement getDestination]];
  [m_colorWell setColor:[m_pageElement getColor]];
}

- (CPAction)accept:(id)sender
{
  [m_pageElement setLinkTitle:[m_linkTitle stringValue]];
  [m_pageElement setLinkDestination:[m_linkDestination stringValue]];
  [m_pageElement setLinkColor:[m_colorWell color]];
  [m_pageElement updateServer];
  [_window close];
}

@end
