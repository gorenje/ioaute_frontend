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
  [m_pageElement pushState];
  [[CPNotificationCenter defaultCenter]
      addObserver:self
         selector:@selector(windowWillClose:)
             name:CPWindowWillCloseNotification
           object:_window];
}

- (void) windowWillClose:(CPNotification)aNotification
{
  // some property windows open a color panel, close just in case.
  [[CPColorPanel sharedColorPanel] close];
}
  
- (CPAction)cancel:(id)sender
{
  [m_pageElement popState];
  [_window close];
}

- (void)setFocusOn:(CPView)aView
{
  [_window makeFirstResponder:aView];
}

// TODO could implement this BUT we need to captcha: 'cancel:', 'accept:' and the 
// TODO close button at the top-left of each window .... the 'x' at the top left
// TODO need to be removed via interface builder.
// - (void)runModal
// {
//   [self loadWindow];
//   [CPApp runModalForWindow:_window];
// }

@end
