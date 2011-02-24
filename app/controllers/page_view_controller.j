var PageViewControllerInstance = nil;

var PagesButtonBar = [
             '{ "name" : "-", "type": "button", "selector": "removePage:" }',
             '{ "name" : "+", "type": "button", "selector": "addPage:" }',
             '{ "name" : "C", "type": "button", "selector": "copyPage:" }',
             '{ "name" : "P", "type": "button", "selector": "openProperties:" }',
             '{ "name" : "", "type": "label" }',
             '{ "name" : "", "type": "label" }',
             '{ "name" : "", "type": "label" }',
             '{ "name" : "", "type": "label" }'
        ];

@implementation PageViewController : CPObject
{
  PageNumberView m_pageNumberView;
  CPCollectionView m_pageCtrlView;

  CPString currentPage @accessors;
}

- (id)init
{
  self = [super init];
  if (self) {
    [AlertWindowSupport addToClassOfObject:self];
    var jsonObject = new Object();
    jsonObject.number = "1";
    jsonObject.name = "Page";
    jsonObject.id = 1;
    jsonObject.page = jsonObject;
    currentPage = [[Page alloc] initWithJSONObject:jsonObject];
  }
  return self;
}

+ (PageViewController) sharedInstance 
{
  if ( !PageViewControllerInstance ) {
    PageViewControllerInstance = [[PageViewController alloc] init];
  }
  return PageViewControllerInstance;
}

+ (CPView) createListPageNumbersView:(CGRect)aRect
{
  var aView = [[PageNumberView alloc] initWithFrame:aRect];
  var pageNumberListItem = [[CPCollectionViewItem alloc] init];
  [pageNumberListItem setView:[[PageNumberListCell alloc] initWithFrame:CGRectMakeZero()]];

  [aView setDelegate:[PageViewController sharedInstance]];
  [aView setItemPrototype:pageNumberListItem];
  [aView setMinItemSize:CGSizeMake(10.0, 35.0)];
  [aView setMaxItemSize:CGSizeMake([ThemeManager sideBarWidth], 35.0)];
  [aView setMaxNumberOfColumns:1];
  [aView setVerticalMargin:0.0];
  [aView setAutoresizingMask:CPViewHeightSizable];
  [aView setSelectable:YES];
  [aView setAllowsMultipleSelection:NO];
  [aView setAllowsEmptySelection:NO];

  [PageViewController sharedInstance].m_pageNumberView = aView;
  return aView;
}

+ (CPView) createPageControlView:(CGRect)aRect
{
  var aView = [[CPCollectionView alloc] initWithFrame:aRect];
  var pageNumberListItem = [[CPCollectionViewItem alloc] init];
  [pageNumberListItem setView:[[PageControlCell alloc] initWithFrame:CGRectMakeZero()]];

  var borderBox = [[CPBox alloc] initWithFrame:aRect];
  [borderBox setBorderWidth:1.0];
  [borderBox setBorderColor:[ThemeManager borderColor]];
  [borderBox setBorderType:CPLineBorder];
  [borderBox setFillColor:[CPColor whiteColor]];
  [borderBox setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];

  [aView setDelegate:[PageViewController sharedInstance]];
  [aView setItemPrototype:pageNumberListItem];
  var no_columns = PagesButtonBar.length;
  var item_cell_size = CGSizeMake(CGRectGetWidth(aRect)/no_columns, 
                                  CGRectGetHeight(aRect)-1);
  [aView setMinItemSize:item_cell_size];
  [aView setMaxItemSize:item_cell_size];
  [aView setMaxNumberOfColumns:no_columns];
  [aView setMaxNumberOfRows:1];
  [aView setVerticalMargin:0.0];
  [aView setAutoresizingMask:CPViewNotSizable];
  [aView setBackgroundColor:[ThemeManager bgColorPageCtrlView]];
  
  [aView setContent:[PageViewController allPageCtrlButtons]];
  [PageViewController sharedInstance].m_pageCtrlView = aView;

  [borderBox addSubview:aView];
  return borderBox;
}

+ (CPArray)allPageCtrlButtons
{
  var ctrls = [];
  var idx = PagesButtonBar.length;
  while ( idx-- ) {
    ctrls.push([PagesButtonBar[idx] objectFromJSON]);
  }
  return ctrls;
}

//
// Collection view change handler.
//
- (void)collectionViewDidChangeSelection:(CPCollectionView)aCollectionView
{
  if ( aCollectionView == m_pageNumberView ) {
    var selectionIndex = [m_pageNumberView selectionIndexes];
    if ( [selectionIndex lastIndex] > -1 ) {
      var pageObj = [[m_pageNumberView content] objectAtIndex:[selectionIndex lastIndex]];
      [self setCurrentPage:pageObj];
      CPLogConsole( "[PVC] page number is now: " + [self currentPage]);
      [[CPNotificationCenter defaultCenter] 
        postNotificationName:PageViewPageNumberDidChangeNotification
                      object:pageObj];
    }
  }
}

//
// Communication actions and response handler.
//
- (void)sendOffRequestForPageNames
{
  var ary = [[ConfigurationManager sharedInstance] pagesPlaceholders];
  var pages = [];
  for ( var idx = 0; idx < [ary count]; idx++ ) {
    pages.push([[Page alloc] initWithJSONObject:[ary[idx] objectFromJSON]]);
  }
  [m_pageNumberView setContent:pages];
  [m_pageNumberView setSelectionIndexes:[CPIndexSet indexSetWithIndex:0]];
  
  // Hm, since we know that the document view could potentially be interested in the 
  // the results from the server, we ensure that it's already initialized.
  [DocumentViewController sharedInstance];
  [[CommunicationManager sharedInstance] 
    pagesForPublication:self 
               selector:@selector(pageRequestCompleted:)];
}

- (void)pageRequestCompleted:(JSObject)data 
{
  CPLogConsole( "[PVC] got action: " + data.action );
  switch ( data.action ) {

  case "pages_index":
    if ( data.status == "ok" ) {
      var pages = [Page initWithJSONObjects:data.data];
      [[CPNotificationCenter defaultCenter]
        postNotificationName:PageViewRetrievedPagesNotification object:pages];
      [m_pageNumberView setContent:pages];
      [m_pageNumberView reloadContent];
      [m_pageNumberView setSelectionIndexes:[CPIndexSet indexSetWithIndex:0]];
    }
    break;

  case "pages_copy":
    if ( data.status == "ok" ) {
      new_page = [[Page alloc] initWithJSONObject:data.data];
      [[DocumentViewController sharedInstance] 
        addPageToStore:new_page
        withPageElements:data.data.page.page_elements];

      [m_pageNumberView setContent:[[m_pageNumberView content] arrayByAddingObject:new_page]];
      [m_pageNumberView reloadContent];
      // select the last page, this is the new page.
      [m_pageNumberView 
        setSelectionIndexes:[CPIndexSet 
                              indexSetWithIndex:[[m_pageNumberView content] count] -1]];
      [m_pageNumberView scrollToSelection];
      [self awsCloseAlertWindowImmediately];
    }
    break;

  case "pages_new":
    if ( data.status == "ok" ) {
      // We get a back a list of all pages, so this will recreate all page cell views.
      [m_pageNumberView setContent:[Page initWithJSONObjects:data.data]];
      [m_pageNumberView reloadContent];
      // select the last page, this is the new page.
      [m_pageNumberView setSelectionIndexes:[CPIndexSet indexSetWithIndex:data.data.length-1]];
      [m_pageNumberView scrollToSelection]; 
    }
    break;

  case "pages_reorder":
    if ( data.status == "ok" ) {
      CPLogConsole("[PVC] page reordering worked" );
    } else {
      CPLogConsole("[PVC] page reordering FAILED" );
    }
    break;

  case "pages_destroy":
    if ( data.status == "ok" ) {
      CPLogConsole("[PVC] posting deleted page notification");
      [[CPNotificationCenter defaultCenter]
        postNotificationName:PageViewPageWasDeletedNotification
                      object:[[Page alloc] initWithJSONObject:data.data]];
    }
    break;
  }
}

- (Page)currentPageObj
{
  return [[m_pageNumberView content] 
           objectAtIndex:[[m_pageNumberView selectionIndexes] lastIndex]];
}

- (void)updatePageNameForPage:(Page)aPage
{
  var pages = [m_pageNumberView content];
  var destIdx = -1;
  for ( var idx = 0; idx < [pages count]; idx++ ) {
    if ( [pages[idx] pageIdx] == [aPage pageIdx] ) {
      destIdx = idx; 
      break;
    }
  }
  if ( destIdx > -1 ) {
    [[m_pageNumberView items][destIdx] setRepresentedObject:pages[destIdx]];
  }
}

- (void)scrollPageIntoView:(CGRect)aFrame
{
  [m_pageNumberView scrollRectToVisible:aFrame];
}

//
// Drag and drop used to change the page ordering.
//
- (CPData)collectionView:(CPCollectionView)aCollectionView
   dataForItemsAtIndexes:(CPIndexSet)indices 
                 forType:(CPString)aType
{
  if ( aCollectionView != m_pageNumberView ) return nil;

  var idx_store = [];
  [indices getIndexes:idx_store maxCount:([indices count] + 1) inIndexRange:nil];
  var data = [];
  for (var idx = 0; idx < [idx_store count]; idx++) {
    [data addObject:idx_store[idx]];
  }
  return [CPKeyedArchiver archivedDataWithRootObject:data];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView 
   dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
  if ( aCollectionView == m_pageNumberView ) {
    return [PageNumberDragType];
  } else {
    return nil;
  }
}

// Callbacks from a page name list cell to inform us of a change to the ordering.
// Target index is an index in the contents array of the pageNumberView. Page object
// is the dropped-on object, i.e. the target wants to go above/below the page object.
- (void)insertPageAbove:(int)aTargetIndex page:(Page)aPage
{
  var pages = [m_pageNumberView content];
  var destIdx = -1;
  for ( var idx = 0; idx < [pages count]; idx++ ) {
    if ( [pages[idx] pageIdx] == [aPage pageIdx] ) {
      destIdx = idx; 
      break;
    }
  }

  var oldPage = pages[aTargetIndex];
  [pages removeObjectAtIndex:aTargetIndex];
  [pages insertObject:oldPage atIndex:destIdx];

  [m_pageNumberView setContent:[self updatePageNumbers:pages]];
  [m_pageNumberView reloadContent];
  [m_pageNumberView setSelectionIndexes:[CPIndexSet indexSetWithIndex:destIdx]];
}

- (CPArry)updatePageNumbers:(CPArray)pages
{
  var pageNumber = 1;
  for ( var idx = 0; idx < [pages count]; idx++ ) [pages[idx] setNumber:(pageNumber++)];
  [[CommunicationManager sharedInstance] 
    reorderPages:pages 
        delegate:self 
        selector:@selector(pageRequestCompleted:)];
  return pages;
}

//
// Actions
//

- (void)addPage:(id)sender
{
  [[CommunicationManager sharedInstance]
    newPageForPublication:@"Page"
                 delegate:self
                 selector:@selector(pageRequestCompleted:)];
}

- (void)removePage:(id)sender
{
  var selectionIndex = [m_pageNumberView selectionIndexes];
  var content        = [m_pageNumberView content];
  var indexOfObj     = [selectionIndex lastIndex];
  var pageObj        = [content objectAtIndex:indexOfObj];

  // TODO this should be done after the communication manage says that the page
  // TODO got deleted on the server side but this is not done then since the page
  // TODO seletion might well have changed by then .... especially if several
  // TODO pages are being deleted.
  [content removeObjectAtIndex:indexOfObj];
  [m_pageNumberView setContent:content];
  [m_pageNumberView reloadContent];

  if ( [content count] > 0 ) {
    if ( indexOfObj > 1 ) {
      [m_pageNumberView setSelectionIndexes:[CPIndexSet indexSetWithIndex:indexOfObj-1]];
    } else {
      [m_pageNumberView setSelectionIndexes:[CPIndexSet indexSetWithIndex:0]];
    }
  } else {
    [[CPNotificationCenter defaultCenter]
        postNotificationName:PageViewLastPageWasDeletedNotification
                      object:self];
  }
  [m_pageNumberView scrollToSelection];

  [[CommunicationManager sharedInstance] 
    deletePageForPublication:pageObj
                    delegate:self
                    selector:@selector(pageRequestCompleted:)];
}

- (void)openProperties:(id)sender
{
  var controller = [PropertyPageController alloc];
  [controller initWithWindowCibName:PagePropertyWindowCIB];
  [controller showWindow:self];
}

- (void)copyPage:(id)sender
{
  [self awsShowAlertWindow:@"Page being copied - Please Wait"
                     title:@"Page copying ..."
                  interval:15
                  delegate:nil
                  selector:nil];
  [[CommunicationManager sharedInstance] 
    copyPage:[self currentPageObj]
    delegate:self
    selector:@selector(pageRequestCompleted:)];
}

@end
