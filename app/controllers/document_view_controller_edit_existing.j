/* 
   Avoid mutex issues by filling a new page store and only retrieving data from the
   existing store if the page is viewed. This means we have a single point in time
   where we can merge the data.
*/
@implementation DocumentViewControllerEditExisting : DocumentViewController
{
  CPDictionary m_existingPages;
}

- (id)init
{
  CPLogConsole( "[DVCEE] Initializing, editing existing");
  self = [super init];
  if (self) {
    m_existingPages = [[CPDictionary alloc] init];
    [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(pagesWereRetrieved:)
                   name:PageViewRetrievedPagesNotification
                 object:nil];
  }
  return self;
}

- (void)pagesWereRetrieved:(CPNotification)aNotification
{
  var pages = [aNotification object];
  for ( var idx = 0 ; idx < [pages count]; idx++ ) {
    [[CommunicationManager sharedInstance] pageElementsForPage:pages[idx]
                                                      delegate:self 
                                                      selector:@selector(pageRequestCompleted:)];
  }
}

- (CPArray)getStoreForPage:(CPString)pageNumber
{
  var local_store = [m_existingPages objectForKey:pageNumber];
  if ( !local_store ) {
    local_store = [[CPArray alloc] init];
    [m_existingPages setObject:local_store forKey:pageNumber];
  }
  return local_store;
}

- (void)pageRequestCompleted:(JSObject)data 
{
  CPLogConsole( "[DVCEE] got action: " + data.action );
  switch ( data.action ) {
  case "pages_show":
    if ( data.status == "ok" ) {
      var pageData = data.data.page;
      var pageNumber = pageData.number;
      // check whether the page has any page_elements, we know that the m_existingPages 
      // does not contain anything for this page since this is called exactly once (ASSUMPTION)
      // so we can replace the content in the m_existingPages to indicate a) we have 
      // recieved data for the page and b) there aren't any elements. As opposed to we have
      // not yet recieved anything for this page.
      if ( pageData.page_elements.length > 0 ) 
        [[self getStoreForPage:pageNumber]
          addObjectsFromArray:[PageElement
                                createObjectsFromServerJson:pageData.page_elements]];
      }
    break;
  }
}

// This gets called to retrieve the store, this then includes the existing page elements
// into the store.
- (CPArray) currentStore
{
  CPLogConsole( "[DVCEE] current store being called" );
  var current_page = [self currentPage];
  var local_store = [super currentStore];

  CPLogConsole( "[DVCEE] type of " + typeof(current_page));
  var existing_store = [self getStoreForPage:current_page];

  CPLogConsole( "[DVCEE] Existing Store: " + existing_store);
  if ([existing_store count] > 0) {
    [local_store addObjectsFromArray:existing_store];
    [existing_store removeAllObjects];
  }
  return local_store;
}


@end
