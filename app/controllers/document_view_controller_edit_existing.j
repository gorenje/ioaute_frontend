/* 
   Avoid mutex issues by filling a new page store and only retrieving data from the
   existing store if the page is viewed. This means we have a single point in time
   where we can merge the data.
*/
@implementation DocumentViewControllerEditExisting : DocumentViewController
{
  CPDictionary m_existingPages;
  int m_pagesToLoad;
  CPAlert m_alert;
  CPTimer m_timer;
}

- (id)init
{
  CPLogConsole( "[DVCEE] Initializing, editing existing");
  self = [super init];
  if (self) {
    m_existingPages = [[CPDictionary alloc] init];
    m_pagesToLoad = 0;

    [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(pagesWereRetrieved:)
                   name:PageViewRetrievedPagesNotification
                 object:nil];

    [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(allPagesWereLoaded:)
                   name:DocumentViewControllerAllPagesLoaded
                 object:self];

    m_alert = [[CPAlert alloc] init];
    [m_alert setMessageText:@"Publication is loading - Please Wait"];
    [m_alert setTitle:@"Publication Loading ..."];
    [m_alert setAlertStyle:CPInformationalAlertStyle];
    [m_alert setEnabled:NO];
    [m_alert setSelectable:NO];
    [m_alert setEditable:NO];
    [m_alert runModal];

    // remove the dialog window after 15 seconds -- this can happen if the server
    // is unavailable (i.e. no internet).
    var stopInvoker = [[CPInvocation alloc] initWithMethodSignature:nil];
    [stopInvoker setTarget:self];
    [stopInvoker setSelector:@selector(allPagesWereLoaded:)];
    m_timer = [CPTimer scheduledTimerWithTimeInterval:15
                                           invocation:stopInvoker
                                              repeats:NO];
  }
  return self;
}

- (void)pagesWereRetrieved:(CPNotification)aNotification
{
  var pages = [aNotification object];
  m_pagesToLoad = [pages count];
  for ( var idx = 0 ; idx < m_pagesToLoad; idx++ ) {
    [[CommunicationManager sharedInstance] pageElementsForPage:pages[idx]
                                                      delegate:self 
                                                      selector:@selector(pageRequestCompleted:)];
  }
}

- (void)allPagesWereLoaded:(CPNotification)aNotification
{
  [m_timer invalidate];
  [m_documentView setContent:[self currentStore]];
  [m_alert close];
}

- (CPArray)getStoreForPage:(Page)pageObj
{
  var local_store = [m_existingPages objectForKey:[pageObj pageIdx]];
  if ( !local_store ) {
    local_store = [[CPArray alloc] init];
    [m_existingPages setObject:local_store forKey:[pageObj pageIdx]];
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
      var pageObj = [[Page alloc] initWithJSONObject:data.data];

      // check whether the page has any page_elements, we know that the m_existingPages 
      // does not contain anything for this page since this is called exactly once (ASSUMPTION)
      // so we can replace the content in the m_existingPages to indicate a) we have 
      // recieved data for the page and b) there aren't any elements. As opposed to we have
      // not yet recieved anything for this page.
      if ( pageData.page_elements.length > 0 ) {
        [[self getStoreForPage:pageObj]
          addObjectsFromArray:[PageElement
                                createObjectsFromServerJson:pageData.page_elements]];
      }
    }

    // post notification that all pages are now loaded. this is important for the
    // first page.
    if ( --m_pagesToLoad == 0 ) {
      [[CPNotificationCenter defaultCenter] 
        postNotificationName:DocumentViewControllerAllPagesLoaded
                      object:self];
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
  var existing_store = [m_existingPages objectForKey:current_page];

  if (existing_store && [existing_store count] > 0) {
    [local_store addObjectsFromArray:existing_store];
    [existing_store removeAllObjects];
  }
  return local_store;
}

@end
