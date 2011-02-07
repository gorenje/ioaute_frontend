@implementation YouTubeController : CPWindowController
{
  @outlet CPCollectionView m_photoView;
  @outlet CPTextField      m_searchTerm;
  @outlet CPImageView      m_spinnerImage;
  @outlet CPScrollView     m_scrollView;
  @outlet CPTextField      m_indexField;

  CPTimer m_timer;
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

  [CPBox makeBorder:m_scrollView];

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

//
// Button action to retrieve the tweets
//
- (CPAction) doSearch:(id)sender
{
  var userInput = [m_searchTerm stringValue];
    
  if (userInput && userInput !== "") {
    [m_spinnerImage setHidden:NO];
    [PMCMWjsonpWorker workerWithUrl:[YouTubeVideo searchUrlFor:userInput] delegate:self 
                           selector:@selector(loadPhotos:) callback:"callback"];
  }
}

//
// JSONP Request callback
//
- (void)loadPhotos:(JSObject)data
{
  var flickrPhotos = [YouTubeVideo initWithJSONObjects:data.data.items];
  [m_photoView setContent:flickrPhotos];
  [[DragDropManager sharedInstance] moreYouTubeVideos:flickrPhotos];
  [m_photoView setSelectionIndexes:[CPIndexSet indexSet]];
  [m_spinnerImage setHidden:YES];
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
