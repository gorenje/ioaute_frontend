@implementation GoogleImagesController : CPWindowController
{
  @outlet CPCollectionView m_photoView;
  @outlet CPTextField      m_searchTerm;
  @outlet CPImageView      m_spinnerImage;
  @outlet CPScrollView     m_scrollView;

  CPString m_next_photos_page_url;
  CPTimer m_timer;
}

- (void)awakeFromCib
{
  var photoItem = [[CPCollectionViewItem alloc] init];
  [photoItem setView:[[GoogleImagesPhotoCell alloc] 
                       initWithFrame:CGRectMake(0, 0, 150, 150)]];

  [m_photoView setDelegate:self];
  [m_photoView setItemPrototype:photoItem];
  [m_photoView setSelectable:YES];
  [m_photoView setAllowsMultipleSelection:YES];
  [m_photoView setMinItemSize:CGSizeMake(150, 150)];
  [m_photoView setMaxItemSize:CGSizeMake(150, 150)];
  [m_photoView setAutoresizingMask:CPViewWidthSizable];

  [m_spinnerImage setImage:[[PlaceholderManager sharedInstance] spinner]];
  [m_spinnerImage setHidden:YES];

  [m_searchTerm setTarget:self];
  [m_searchTerm setAction:@selector(doSearch:)];
  [m_searchTerm setStringValue:[[[ConfigurationManager sharedInstance] topics] anyValue]];

  [self doSearch:self];
  [[CPNotificationCenter defaultCenter] 
    addObserver:self
       selector:@selector(windowWillClose:)
           name:CPWindowWillCloseNotification
         object:_window];

}

- (void) windowWillClose:(CPNotification)aNotification
{
  // Cleanup
  [[CPNotificationCenter defaultCenter] removeObserver:self];
  [m_timer invalidate];
}

//
// Following are used to monitor the vertical scrollbar and if the users scrolls to
// the bottom, trigger a refresh of the content with page two of the search results.
//
- (void) setupScrollerObserver
{
  // Because there are no notifications that we can listen for to tell us that
  // the scroller (vertical) has reached the bottom, we start a timer and let it
  // check the start of the scroller.
  var scrollerObserver = [[CPInvocation alloc] initWithMethodSignature:nil];
  [scrollerObserver setTarget:self];
  [scrollerObserver setSelector:@selector(checkVerticalScroller:)];
  if ( m_timer ) [m_timer invalidate];
  m_timer = [CPTimer scheduledTimerWithTimeInterval:0.5
                                         invocation:scrollerObserver
                                            repeats:YES];
}

- (void)checkVerticalScroller:(id)obj
{
  // scroller value ranges between 0 and 1, with one being bottom.
  if ( m_next_photos_page_url && [[m_scrollView verticalScroller] floatValue] == 1 ) {
    [m_timer invalidate];
    [m_spinnerImage setHidden:NO];
    [PMCMWjsonpWorker workerWithUrl:m_next_photos_page_url
                           delegate:self 
                           selector:@selector(loadPhotos:) 
                           callback:"callback"];
  }
}

//
// Button action to retrieve the tweets
//
- (CPAction) doSearch:(id)sender
{
  var userInput = [m_searchTerm stringValue];
    
  if (userInput && userInput !== "") {
    [m_spinnerImage setHidden:NO];
    [m_photoView setContent:[]];
    // TODO remove only data from drag&drop manager
    [PMCMWjsonpWorker workerWithUrl:[GoogleImage searchUrlFor:userInput] 
                           delegate:self 
                           selector:@selector(loadPhotos:) 
                           callback:"callback"];
  }
}

//
// JSONP Request callback
//
- (void)loadPhotos:(JSObject)data
{
  var flickrPhotos = [GoogleImage initWithJSONObjects:data.responseData.results];

  var content = [[m_photoView content] arrayByAddingObjectsFromArray:flickrPhotos];
  [m_photoView setContent:content];
  [[DragDropManager sharedInstance] moreGoogleImages:flickrPhotos];
  [m_photoView setSelectionIndexes:[CPIndexSet indexSet]];
  [m_spinnerImage setHidden:YES];

  // only setup the observer if we got photos back for this request. If not, then there
  // no more pictures to be had for this search term.
  m_next_photos_page_url = [GoogleImage searchUrlNextPage:data.responseData.cursor
                                               searchTerm:[m_searchTerm stringValue]];
  if ( m_next_photos_page_url ) {
    [self setupScrollerObserver];
  } else {
    [m_timer invalidate];
  }
}

//
// The magic of drag and drop
//
- (CPData)collectionView:(CPCollectionView)aCollectionView 
   dataForItemsAtIndexes:(CPIndexSet)indices 
                 forType:(CPString)aType
{
  var idx_store = [];
  [indices getIndexes:idx_store maxCount:([indices count] + 1) inIndexRange:nil];

  var data = [];
  var flickrObjs = [m_photoView content];
  for (var idx = 0; idx < [idx_store count]; idx++) {
    [data addObject:[flickrObjs[idx_store[idx]] id_str]];
  }

  return [CPKeyedArchiver archivedDataWithRootObject:data];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView 
dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
  return [GoogleImagesDragType];
}

@end
