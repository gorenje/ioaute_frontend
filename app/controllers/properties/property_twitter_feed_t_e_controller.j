@implementation PropertyTwitterFeedTEController : PropertyWindowController
{
  @outlet CPTextField m_forUserField;
}

- (void)awakeFromCib
{
  [m_forUserField setStringValue:[m_pageElement getForUser]];
}

- (CPAction)accept:(id)sender
{
  [m_pageElement setForUser:[m_forUserField stringValue]];
  [m_pageElement updateServer];
  [_window close];
}

@end
