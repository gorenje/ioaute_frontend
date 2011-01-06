/*
 * Controller for managing the document view which is our publication or 
 * rather one page of that publication.
 *
 * This stores all the PageElement objects for all the pages in the current document.
 * The DocumentView manages the DocumentViewCells and nothing else. The PageElement
 * and DocumentViewCell send messages, at least partially, direct to this singleton
 * class. This class is then responsible for updating the DocumentView.
 */

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

+ (DocumentView) createDocumentView:(CGRect)aRect
{
  [DocumentViewController sharedInstance]._documentView = 
    [[DocumentView alloc] initWithFrame:aRect];
  return [DocumentViewController sharedInstance]._documentView;
}

- (CPString)currentPage
{
  return [[ConfigurationManager sharedInstance] pageNumber];
}

- (CPArray)currentStore
{
  var current_page = [self currentPage];
  var localStore = [_pageStore objectForKey:current_page];
  if ( !localStore ) {
    localStore = [[CPArray alloc] init];
    [_pageStore setObject:localStore forKey:current_page];
  }
  return localStore;
}

//
// Notifications
//
- (void)pageNumberDidChange:(CPNotification)aNotification
{
  var sender = [aNotification object];
  CPLogConsole('[DVC] page number did change: ' + sender);
  // hide editor highlight
  [[DocumentViewEditorView sharedInstance] setDocumentViewCell:nil];
  [_documentView setContent:[_pageStore objectForKey:[self currentPage]]];
}

//
// Callbacks from the document view.
//
- (void)draggedObjects:(CPArray)pageElements atLocation:(CGPoint)aLocation
{
  // store for pagination
  [[self currentStore] addObjectsFromArray:pageElements];
  // display on the current page
  [_documentView addObjectsToView:pageElements atLocation:aLocation];
  // finally add to server -- now they have their correct locations.
  for ( var idx = 0; idx < pageElements.length; idx++ ) {
    [pageElements[idx] addToServer];
  }
}

//
// Callback from PageElement
//
- (void)removeObject:(PageElement)obj
{
  var keys = [_pageStore allKeys];
  for ( var idx = 0; idx < keys.length; idx++ ) {
    [[_pageStore objectForKey:keys[idx]] removeObjectIdenticalTo:obj];
  }
}

@end
