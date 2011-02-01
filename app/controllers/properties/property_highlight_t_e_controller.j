@implementation PropertyHighlightTEController : PropertyWindowController
{
  @outlet CPColorWell m_colorWell;
}

- (void)awakeFromCib
{
  [m_colorWell setColor:[m_pageElement getColor]];
}

- (CPAction)accept:(id)sender
{
  [m_pageElement setHighlightColor:[m_colorWell color]];
  [m_pageElement updateServer];
  [_window close];
}

@end
