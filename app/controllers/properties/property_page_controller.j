@implementation PropertyPageController : PropertyWindowController
{
  @outlet CPColorWell   m_colorWell;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [CPBox makeBorder:m_colorWell];
  [m_colorWell setColor:[[DocumentViewController sharedInstance] backgroundColor]];
}

- (CPAction)updateColor:(id)sender
{
  [[DocumentViewController sharedInstance] setBackgroundColor:[m_colorWell color]];
}

- (CPAction)accept:(id)sender
{
  [_window close];
}

@end
