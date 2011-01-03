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
  [aView setMinItemSize:CGSizeMake(20.0, 45.0)];
  [aView setMaxItemSize:CGSizeMake(200.0, 45.0)];
  [aView setMaxNumberOfColumns:1];
  [aView setVerticalMargin:0.0];
  [aView setAutoresizingMask:CPViewHeightSizable];

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
  [aView setMinItemSize:CGSizeMake(40.0, 40.0)];
  [aView setMaxItemSize:CGSizeMake(40.0, 40.0)];
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
  if ( aCollectionView == _pageCtrlView ) {
    CPLogConsole( "[PVC] Some one did something - CONTROL VIEW" );
  } else {
    if ( aCollectionView == _pageNamesView ) {
      CPLogConsole( "[PVC] Some one did something - PAGE NUMBER VIEW" );
    } else {
      CPLogConsole( "[PVC] Some one did something - UNKNOWN VIEW" );
    }
  }
}

//
// Communication actions and response handler.
//
- (void)sendOffRequestForPageNames
{
  // TODO this is just demo data
  var ary = [
             '{ "page" : { "number": "1", "name" : "Page One" }}',
             '{ "page" : { "number": "2", "name" : "Page Two" }}',
             '{ "page" : { "number": "3", "name" : "Page Three" }}',
             '{ "page" : { "number": "4", "name" : "Page Four" }}',
             ];

  var pages = [];
  var idx = ary.length;
  while ( idx-- ) {
    pages.push([[Page alloc] initWithJSONObject:[ary[idx] objectFromJSON]]);
  }
  [_pageNamesView setContent:pages];
  
  [[CommunicationManager sharedInstance] pagesForPublication:self 
                                                    selector:@selector(pageRequestCompleted:)];
}

- (void)pageRequestCompleted:(JSObject)data 
{
  CPLogConsole( "[AppCon] [Page] got action: " + data.action );
  switch ( data.action ) {
  case "pages_index":
    if ( data.status == "ok" ) {
      [_pageNamesView setContent:[Page initWithJSONObjects:data.data]];
    }
    break;
  case "pages_new":
    if ( data.status == "ok" ) {
      [_pageNamesView setContent:[Page initWithJSONObjects:data.data]];
    }
    break;
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
  // TODO implement me.
}

- (void)copyPage:(id)sender
{
  // TODO implement me.
}


@end
