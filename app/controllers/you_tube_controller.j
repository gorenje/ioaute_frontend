@implementation YouTubeController : CPWindowController
{
  @outlet CPCollectionView m_photoView;
  @outlet CPTextField      m_searchTerm;
  @outlet CPImageView      m_spinnerImage;
  @outlet CPScrollView     m_scrollView;
  @outlet CPTextField      m_indexField;

  CPTimer m_timer;
  int m_current_page;
}

- (void)awakeFromCib
{
  var photoItem = [[CPCollectionViewItem alloc] init];
  [photoItem setView:[[YouTubePhotoCell alloc] initWithFrame:CGRectMake(0, 0, 150, 150)]];

  [m_photoView setDelegate:self];
  [m_photoView setItemPrototype:photoItem];
  [m_photoView setSelectable:YES];
  [m_photoView setAllowsMultipleSelection:YES];
  [m_photoView setMinItemSize:CGSizeMake(150, 150)];
  [m_photoView setMaxItemSize:CGSizeMake(150, 150)];
  [m_photoView setAutoresizingMask:CPViewWidthSizable];

  [m_spinnerImage setImage:[[PlaceholderManager sharedInstance] spinner]];
  [m_spinnerImage setHidden:YES];

  [m_searchTerm setStringValue:[[[ConfigurationManager sharedInstance] topics] anyValue]];

  [CPBox makeBorder:m_scrollView];
  m_current_page = 0;

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
  if ( m_timer ) [m_timer invalidate];
}

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
  var indexLabel = [CPString stringWithFormat:"%d of %d", 
                             ([[m_scrollView verticalScroller] floatValue] * 
                              [[m_photoView content] count]),[[m_photoView content] count]];
  [m_indexField setStringValue:indexLabel];

  var userInput = [m_searchTerm stringValue];
  if (userInput && userInput !== "" && [[m_scrollView verticalScroller] floatValue] == 1 ) {
    [m_timer invalidate];
    [m_spinnerImage setHidden:NO];
    [PMCMWjsonpWorker workerWithUrl:[YouTubeVideo searchUrlFor:userInput 
                                                    pageNumber:++m_current_page] 
                           delegate:self 
                           selector:@selector(loadVideos:) callback:"callback"];
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
    m_current_page = 0;
    [m_photoView setContent:[]];
    [PMCMWjsonpWorker workerWithUrl:[YouTubeVideo searchUrlFor:userInput pageNumber:0] 
                           delegate:self 
                           selector:@selector(loadVideos:) callback:"callback"];
  }
}

//
// JSONP Request callback
//
- (void)loadVideos:(JSObject)data
{
  [m_spinnerImage setHidden:YES];
  if ( data.data && data.data.items && data.data.items.length > 0 ) {
    var flickrPhotos = [YouTubeVideo initWithJSONObjects:data.data.items];

    var content = [[m_photoView content] arrayByAddingObjectsFromArray:flickrPhotos];
    [m_photoView setContent:content];
    [[DragDropManager sharedInstance] moreYouTubeVideos:flickrPhotos];
    [m_photoView setSelectionIndexes:[CPIndexSet indexSet]];

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
  return [YouTubeDragType];
}

@end
