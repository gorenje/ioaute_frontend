@import <Foundation/CPObject.j>

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
  [aView setMaxItemSize:CGSizeMake(200.0, 35.0)];
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

  [aView setDelegate:[PageViewController sharedInstance]];
  [aView setItemPrototype:pageNumberListItem];
  [aView setMinItemSize:CGSizeMake(40.0, 30.0)];
  [aView setMaxItemSize:CGSizeMake(40.0, 30.0)];
  [aView setMaxNumberOfColumns:4];
  [aView setMaxNumberOfRows:1];
  [aView setVerticalMargin:0.0];
  [aView setAutoresizingMask:CPViewNotSizable];
  [aView setBackgroundColor:[CPColor colorWithRed:113.0/255.0 
                                            green:121.0/255.0 
                                             blue:220.0/255.0 
                                            alpha:1.0]];
  
  [aView setContent:[PageViewController allPageCtrlButtons]];
  [PageViewController sharedInstance]._pageCtrlView = aView;
  return aView;
}

+ (CPArray)allPageCtrlButtons
{
  var ary = [
             '{ "name" : "-", "type": "button", "selector": "removePage:" }',
             '{ "name" : "+", "type": "button", "selector": "addPage:" }',
             '{ "name" : "C", "type": "button", "selector": "copyPage:" }',
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
  // TODO this is just demo data
  var ary = [
             '{ "page" : { "number": "4", "name" : "Page Four" }}',
             '{ "page" : { "number": "3", "name" : "Page Three" }}',
             '{ "page" : { "number": "2", "name" : "Page Two" }}',
             '{ "page" : { "number": "1", "name" : "Page One" }}',
             ];

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
  var string = prompt("New Page Name");

  if (string) {
    [[CommunicationManager sharedInstance] newPageForPublication:string
                                                        delegate:self 
                                                        selector:@selector(pageRequestCompleted:)];
  }
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
}

@end
