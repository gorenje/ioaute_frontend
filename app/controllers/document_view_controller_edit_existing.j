/*
 * Created by Gerrit Riessen
 * Copyright 2010-2011, Gerrit Riessen
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
/* 
   Avoid mutex issues by filling a new page store and only retrieving data from the
   existing store if the page is viewed. This means we have a single point in time
   where we can merge the data.
*/
@implementation DocumentViewControllerEditExisting : DocumentViewController
{
  CPDictionary m_existingPages;
  int          m_pagesToLoad;
  CPAlert      m_alert;
  CPTimer      m_timer;
}

- (id)init
{
  self = [super init];
  if (self) {
    [AlertWindowSupport addToClassOfObject:self];
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


    [self awsShowAlertWindow:@"Publication is loading - Please Wait"
                       title:@"Publication Loading ..."
                    interval:15
                    delegate:self
                    selector:@selector(alertWindowWasClosedByTimer)];
  }
  return self;
}

- (void)pagesWereRetrieved:(CPNotification)aNotification
{
  var pages = [aNotification object];
  m_pagesToLoad = [pages count];
  for ( var idx = 0 ; idx < m_pagesToLoad; idx++ ) {
    var loadPageInvoker = [[CPInvocation alloc] initWithMethodSignature:nil];
    [loadPageInvoker setTarget:self];
    [loadPageInvoker setSelector:@selector(loadPageData:)];
    [loadPageInvoker setArgument:pages[idx] atIndex:2];
    // avoid making too many requests at the same time, step the page loading
    // requests 0.3 seconds apart.
    [CPTimer scheduledTimerWithTimeInterval:(0.3 * idx)
                                 invocation:loadPageInvoker
                                    repeats:NO];
  }
}

- (void)loadPageData:(Page)pageObj
{
  [[CommunicationManager sharedInstance] 
      pageElementsForPage:pageObj
                 delegate:self 
                 selector:@selector(pageRequestCompleted:)];
}

- (void)alertWindowWasClosedByTimer
{
  [m_documentView setContent:[self currentStore]];
}

- (void)allPagesWereLoaded:(CPNotification)aNotification
{
  [self awsCloseAlertWindowImmediately];
  [m_documentView setContent:[self currentStore]];
}

- (void)pageRequestCompleted:(JSObject)data 
{
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
