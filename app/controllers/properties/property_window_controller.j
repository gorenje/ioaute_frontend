@implementation PropertyWindowController : CPWindowController
{
  PageElement m_pageElement;
}

- (id)initWithWindowCibName:(CPString)cibName pageElement:(id)aPageElement
{
  self = [super initWithWindowCibName:cibName];
  if ( self ) {
    m_pageElement = aPageElement;
  }
  return self;
}

- (CPAction)cancel:(id)sender
{
  [_window close];
}

@end
