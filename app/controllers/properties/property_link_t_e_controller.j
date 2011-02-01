@implementation PropertyLinkTEController : PropertyWindowController
{
  @outlet CPColorWell m_colorWell;
  @outlet CPTextField m_linkDestination;
  @outlet CPTextField m_linkTitle;

  CPColor m_originalColor;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  m_originalColor = [m_pageElement getColor];
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

- (CPAction)cancel:(id)sender
{
  [m_pageElement setLinkColor:m_originalColor];
  [super cancel:sender];
}

- (CPAction)updateColor:(id)sender
{
  [m_pageElement setLinkColor:[m_colorWell color]];
}

@end
