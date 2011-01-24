@implementation FlickrController : CPWindowController
{
  @outlet CPCollectionView _photoView;
  @outlet CPTextField      _searchTerm;
  @outlet CPImageView      _spinnerImage;
  @outlet CPScrollView     m_scrollView;

  int m_currentPageNumber;
  CPArray m_currentCollectionContent;
  CPTimer m_timer;
}

- (void)awakeFromCib
{
  var photoItem = [[CPCollectionViewItem alloc] init];
  [photoItem setView:[[FlickrPhotoCell alloc] initWithFrame:CGRectMake(0, 0, 150, 150)]];

  [_photoView setDelegate:self];
  [_photoView setItemPrototype:photoItem];
  [_photoView setSelectable:YES];
  [_photoView setAllowsMultipleSelection:YES];
    
  [_photoView setMinItemSize:CGSizeMake(150, 150)];
  [_photoView setMaxItemSize:CGSizeMake(150, 150)];
  [_photoView setAutoresizingMask:CPViewWidthSizable];

  [_spinnerImage setImage:[[PlaceholderManager sharedInstance] spinner]];
  [_spinnerImage setHidden:YES];
  [_searchTerm setTarget:self];
  [_searchTerm setAction:@selector(doSearch:)];
  [_searchTerm setStringValue:[[[ConfigurationManager sharedInstance] topics] anyValue]];

  m_currentPageNumber = 1;
  m_currentCollectionContent = [];

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

// required because the twitter controller is the file owner of the Cib.
- (void) setDelegate:(id)anObject
{
  // The AppController is the delegate.
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
  if ( m_timer ) {
    [m_timer invalidate];
  }
  m_timer = [CPTimer scheduledTimerWithTimeInterval:0.5
                                         invocation:scrollerObserver
                                            repeats:YES];
}

- (void)checkVerticalScroller:(id)obj
{
  // scroller value ranges between 0 and 1, with one being bottom.
  var userInput = [_searchTerm stringValue];
  if (userInput && userInput !== "" && [[m_scrollView verticalScroller] floatValue] == 1 ) {
    [m_timer invalidate];
    [_spinnerImage setHidden:NO];
    m_currentPageNumber++;
    [PMCMWjsonpWorker workerWithUrl:[Flickr searchUrl:userInput pageNumber:m_currentPageNumber] 
                           delegate:self 
                           selector:@selector(loadPhotos:) 
                           callback:"jsoncallback"];
  }
}

//
// Button action to retrieve the tweets
//
- (CPAction) doSearch:(id)sender
{
  var userInput = [_searchTerm stringValue];
    
  if (userInput && userInput !== "") {
    [_spinnerImage setHidden:NO];
    m_currentPageNumber = 1;
    m_currentCollectionContent = [];
    // TODO remove flickr from the drag&drop manager
    [PMCMWjsonpWorker workerWithUrl:[Flickr searchUrl:userInput pageNumber:m_currentPageNumber] 
                           delegate:self 
                           selector:@selector(loadPhotos:) 
                           callback:"jsoncallback"];
  }
}

//
// JSONP Request callback
//
- (void)loadPhotos:(JSObject)data
{
  var flickrPhotos = [Flickr initWithJSONObjects:data.photos.photo];
  [m_currentCollectionContent addObjectsFromArray:flickrPhotos];
  [_photoView setContent:m_currentCollectionContent];
  [[DragDropManager sharedInstance] moreFlickrImages:flickrPhotos];
  [_photoView setSelectionIndexes:[CPIndexSet indexSet]];
  [_spinnerImage setHidden:YES];
  // only setup the observer if we got photos back for this request. If not, then there
  // no more pictures to be had for this search term.
  if ( data.photos.photo.length > 0 ) {
    [self setupScrollerObserver];
  }
}

//
// The magic of drag and drop
//
- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
  CPLogConsole( "[FLICKR PHOTO VIEW] preparing data for drag");
  var idx_store = [];
  [indices getIndexes:idx_store maxCount:([indices count] + 1) inIndexRange:nil];

  var data = [];
  var flickrObjs = [_photoView content];
  for (var idx = 0; idx < [idx_store count]; idx++) {
    [data addObject:[flickrObjs[idx_store[idx]] id_str]];
  }
  CPLogConsole( "[FLICKR PHOTO VIEW] Data: " + data );

  return [CPKeyedArchiver archivedDataWithRootObject:data];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
  return [FlickrDragType];
}

@end
