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

- (void)awakeFromCib
{
  [[CPNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(windowWillClose:)
             name:CPWindowWillCloseNotification
           object:_window];
}

- (void) windowWillClose:(CPNotification)aNotification
{
  [[CPColorPanel sharedColorPanel] close];
}
  
- (CPAction)cancel:(id)sender
{
  [_window close];
}

@end
