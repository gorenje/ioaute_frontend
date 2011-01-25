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

    [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(pageWasDeleted:)
                   name:PageViewPageWasDeletedNotification
                 object:nil]; // object is the page being deleted.
  }
  return self;
}

+ (DocumentViewController) sharedInstance 
{
  if ( !DocumentViewControllerInstance ) {
    if ( [[ConfigurationManager sharedInstance] is_new] ) {
      DocumentViewControllerInstance = [[DocumentViewController alloc] init];
    } else {
      DocumentViewControllerInstance = [[DocumentViewControllerEditExisting alloc] init];
    }
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
  return [[[PageViewController sharedInstance] currentPage] pageIdx];
}

// Return the store (i.e. CPDictionary) for the current page. If there is no store
// then create one, store it and return it. This could be done better by capturing the 
// notification for a new page being created. But since there is (at time of writing)
// no notification, that is fairly pointless.
- (CPArray)currentStore
{
  var current_page = [self currentPage];
  var local_store = [_pageStore objectForKey:current_page];
  if ( !local_store ) {
    local_store = [[CPArray alloc] init];
    [_pageStore setObject:local_store forKey:current_page];
  }
  return local_store;
}

//
// Notification from the page view that a new page has been selected. Retrieve
// the contents of the page from the page store.
//
- (void)pageNumberDidChange:(CPNotification)aNotification
{
  // hide editor highlight
  [[DocumentViewEditorView sharedInstance] setDocumentViewCell:nil];
  [_documentView setContent:[self currentStore]];
}

- (void)pageWasDeleted:(CPNotification)aNotification
{
  var pageObj = [aNotification object];
  var local_store = [_pageStore objectForKey:[pageObj pageIdx]];
  if ( local_store ) {
    [local_store removeAllObjects];
  }
}

//
// Callbacks from the document view. A bunch of page elements were just dumped
// into the document view. These are all new and need to be added to the server
// and our store for the current page.
//
- (void)draggedObjects:(CPArray)pageElements atLocation:(CGPoint)aLocation
{
  [[self currentStore] addObjectsFromArray:pageElements];
  [_documentView addObjectsToView:pageElements atLocation:aLocation];
  for ( var idx = 0; idx < pageElements.length; idx++ ) {
    [pageElements[idx] addToServer];
  }
}

//
// Callback from PageElement. The server has been informed by the page element,
// we only need to remove it from our local store for the page.
//
- (void)removeObject:(PageElement)obj
{
  var keys = [_pageStore allKeys];
  for ( var idx = 0; idx < keys.length; idx++ ) {
    [[_pageStore objectForKey:keys[idx]] removeObjectIdenticalTo:obj];
  }
}

@end
