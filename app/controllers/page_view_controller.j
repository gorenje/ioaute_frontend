var PageViewControllerInstance = nil;

@implementation PageViewController : CPObject
{
  CPCollectionView _pageNamesView;
  CPCollectionView _pageCtrlView;
}

- (id)init
{
  self = [super init];
  if (self) {
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
  var aView = [[CPCollectionView alloc] initWithFrame:aRect];
  var pageNumberListItem = [[CPCollectionViewItem alloc] init];
  [pageNumberListItem setView:[[PageNumberListCell alloc] initWithFrame:CGRectMakeZero()]];

  [aView setDelegate:[PageViewController sharedInstance]];
  [aView setItemPrototype:pageNumberListItem];
  [aView setMinItemSize:CGSizeMake(20.0, 35.0)];
  [aView setMaxItemSize:CGSizeMake([ThemeManager sideBarWidth], 35.0)];
  [aView setMaxNumberOfColumns:1];
  [aView setVerticalMargin:0.0];
  [aView setAutoresizingMask:CPViewHeightSizable];
  [aView setSelectable:YES];
  [aView setAllowsMultipleSelection:NO];
  [aView setAllowsEmptySelection:NO];

  [PageViewController sharedInstance]._pageNamesView = aView;
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
  [aView setMinItemSize:CGSizeMake(60.0, CGRectGetHeight(aRect)-1)];
  [aView setMaxItemSize:CGSizeMake(60.0, CGRectGetHeight(aRect)-1)];
  [aView setMaxNumberOfColumns:4];
  [aView setMaxNumberOfRows:1];
  [aView setVerticalMargin:0.0];
  [aView setAutoresizingMask:CPViewNotSizable];
  [aView setBackgroundColor:[ThemeManager bgColorPageCtrlView]];
  
  [aView setContent:[PageViewController allPageCtrlButtons]];
  [PageViewController sharedInstance]._pageCtrlView = aView;

  [borderBox addSubview:aView];
  return borderBox;
}

+ (CPArray)allPageCtrlButtons
{
  var ary = [
             '{ "name" : "-", "type": "button", "selector": "removePage:" }',
             '{ "name" : "+", "type": "button", "selector": "addPage:" }',
              //'{ "name" : "C", "type": "button", "selector": "copyPage:" }',
             '{ "name" : "", "type": "label" }',
             '{ "name" : "Pages", "type": "label" }',
             ];
  var ctrls = [];
  var idx = ary.length;
  while ( idx-- ) {
    ctrls.push([ary[idx] objectFromJSON]);
  }
  return ctrls;
}

//
// Collection view change handler.
//
- (void)collectionViewDidChangeSelection:(CPCollectionView)aCollectionView
{
  if ( aCollectionView == _pageNamesView ) {
    var selectionIndex = [_pageNamesView selectionIndexes];
    var page = [[_pageNamesView content] objectAtIndex:[selectionIndex lastIndex]];
    [[ConfigurationManager sharedInstance] setPageNumber:[page number]];
    CPLogConsole( "[PVC] page number is now: " + [[ConfigurationManager sharedInstance] pageNumber]);
    [[CPNotificationCenter defaultCenter] 
      postNotificationName:PageViewPageNumberDidChangeNotification
                    object:self];
  }
}

//
// Communication actions and response handler.
//
- (void)sendOffRequestForPageNames
{
  var ary = [[ConfigurationManager sharedInstance] pagesPlaceholders];
  var pages = [];
  var idx = ary.length;
  while ( idx-- ) {
    pages.push([[Page alloc] initWithJSONObject:[ary[idx] objectFromJSON]]);
  }
  [_pageNamesView setContent:pages];
  [_pageNamesView setSelectionIndexes:[CPIndexSet indexSetWithIndex:0]];
  
  [[CommunicationManager sharedInstance] pagesForPublication:self 
                                                    selector:@selector(pageRequestCompleted:)];
}

- (void)pageRequestCompleted:(JSObject)data 
{
  CPLogConsole( "[PVC] got action: " + data.action );
  switch ( data.action ) {
  case "pages_index":
    if ( data.status == "ok" ) {
      [_pageNamesView setContent:[Page initWithJSONObjects:data.data]];
      [_pageNamesView reloadContent];
      [_pageNamesView setSelectionIndexes:[CPIndexSet indexSetWithIndex:0]];
    }
    break;

  case "pages_new":
    if ( data.status == "ok" ) {
      [_pageNamesView setContent:[Page initWithJSONObjects:data.data]];
      [_pageNamesView reloadContent];
      [_pageNamesView setSelectionIndexes:[CPIndexSet indexSetWithIndex:data.data.length-1]];
      // TODO post notification that a new page was created ... although it might not 
      // TODO be necessary since the documentViewController automagically creates new
      // TODO content for the page.
    }
    break;

  case "pages_destroy":
    if ( data.status == "ok" ) {
      // TODO post notification with page number that was deleted.
    }
  }
}

//
// Action
//

- (void)addPage:(id)sender
{
  [[CommunicationManager sharedInstance] newPageForPublication:@"Page"
                                                      delegate:self 
                                                      selector:@selector(pageRequestCompleted:)];
}

- (void)removePage:(id)sender
{
  var selectionIndex = [_pageNamesView selectionIndexes];
  CPLogConsole( "Selected was: " + [selectionIndex lastIndex]);
  var content = [_pageNamesView content];
  var page = [content objectAtIndex:[selectionIndex lastIndex]];

  [content removeObjectAtIndex:[selectionIndex lastIndex]];
  [_pageNamesView setContent:content];
  [_pageNamesView reloadContent];
  [_pageNamesView setSelectionIndexes:[CPIndexSet indexSetWithIndex:0]];
  [[CommunicationManager sharedInstance] deletePageForPublication:page];
}

- (void)copyPage:(id)sender
{
  // TODO implement me.
  alertUserWithTodo("No Page Copying yet");
}

@end
