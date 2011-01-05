/*
 * Controller for managing the document view which is our publication or 
 * rather one page of that publication.
 */
@import <Foundation/CPObject.j>

var DocumentViewControllerInstance = nil;

@implementation DocumentViewController : CPObject
{
  CPDictionary _pageStore;
  DocumentView _documentView;
}

- (id)init
{
  self = [super init];
  if (self) {
    _pageStore = [[CPDictionary alloc] init];

    [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(pageNumberDidChange:)
                   name:PageViewPageNumberDidChangeNotification
                 object:[PageViewController sharedInstance]];

    [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(documentViewContentDidChange:)
                   name:DocumentViewContentDidChangeNotification
                 object:nil];
  }
  return self;
}

+ (DocumentViewController) sharedInstance 
{
  if ( !DocumentViewControllerInstance ) {
    DocumentViewControllerInstance = [[DocumentViewController alloc] init];
  }
  return DocumentViewControllerInstance;
}

//
// Notifications
//
- (void)documentViewContentDidChange:(CPNotification)aNotification
{
  CPLogConsole("[DVC] document view did change content");
  [_pageStore setObject:[_documentView content] 
                 forKey:[[ConfigurationManager sharedInstance] pageNumber]];
}

- (void)pageNumberDidChange:(CPNotification)aNotification
{
  var sender = [aNotification object];
  CPLogConsole('[DVC] page number did change: ' + sender);
  [[DocumentViewEditorView sharedInstance] setDocumentViewCell:nil]; // hide editor highlight
  [_documentView setContent:[_pageStore objectForKey:[[ConfigurationManager sharedInstance] pageNumber]]];
}

//
// Creation.
//
- (DocumentView) createDocumentView:(CGRect)aRect
{
  _documentView = [[DocumentView alloc] initWithFrame:aRect];
  return _documentView;
}
@end
