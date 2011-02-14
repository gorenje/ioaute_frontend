@implementation PropertyHighlightTEController : PropertyWindowController
{
  @outlet CPColorWell m_colorWell;
  CPColor m_originalColor;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [CPBox makeBorder:m_colorWell];
  m_originalColor = [m_pageElement getColor];
  [m_colorWell setColor:[m_pageElement getColor]];
}

- (CPAction)accept:(id)sender
{
  [m_pageElement setHighlightColor:[m_colorWell color]];
  [m_pageElement updateServer];
  [_window close];
}

- (CPAction)cancel:(id)sender
{
  [m_pageElement setHighlightColor:m_originalColor];
  [super cancel:sender];
}

- (CPAction)updateColor:(id)sender
{
  [m_pageElement setHighlightColor:[m_colorWell color]];
}

@end
