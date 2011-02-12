/*
 * This might be the page property controller, however we never communicate directly
 * with the page object, rather via the document view controller (DVC). The DVC 
 * responsible for maintaining the document view in the editor, so it also needs 
 * to know about color changes etc. Therefore it makes sense that the DVC notifies the
 * current page object of any changes.
 */
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
  [[DocumentViewController sharedInstance] updateServer];
  [_window close];
}

@end
