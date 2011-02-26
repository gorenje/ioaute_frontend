var FBBasicData = nil,
  FBMeBaseUrl = @"https://graph.facebook.com/me",
  FBBaseGraphUrl = @"https://graph.facebook.com";
  
@implementation FacebookController : CPWindowController
{
  @outlet CPImageView      m_spinnerView;
  @outlet CPImageView      m_profileImage;
  @outlet CPCollectionView m_photoView;
  @outlet CPCollectionView m_categoryView;
  @outlet CPScrollView     m_scrollView;
  @outlet CPTextField      m_contentName;
  @outlet CPSplitView      m_splitView;
  @outlet CPButton         m_updateButton;

  CPDictionary m_cookieValues;
  CPString m_next_photos_page_url;
  CPTimer m_timer;
  CPObject m_fbAlbumsData;
}

- (void)awakeFromCib
{
  m_cookieValues = getQueryVariables([[ConfigurationManager sharedInstance] fbCookie]);

  var photoItem = [[CPCollectionViewItem alloc] init];
  [photoItem setView:[[FacebookPhotoCell alloc] initWithFrame:CGRectMake(0, 0, 150, 150)]];
  [m_photoView setDelegate:self];
  [m_photoView setItemPrototype:photoItem];
  [m_photoView setSelectable:YES];
  [m_photoView setAllowsMultipleSelection:YES];
  [m_photoView setMinItemSize:CGSizeMake(150, 150)];
  [m_photoView setMaxItemSize:CGSizeMake(150, 150)];
  [m_photoView setAutoresizingMask:CPViewWidthSizable];

  var categoryItem = [[CPCollectionViewItem alloc] init];
  [categoryItem setView:[[FacebookCategoryCell alloc] initWithFrame:CGRectMake(0, 0, 45, 45)]];
  [m_categoryView setDelegate:self];
  [m_categoryView setSelectable:YES];
  [m_categoryView setAllowsMultipleSelection:NO];
  [m_categoryView setItemPrototype:categoryItem];
  [m_categoryView setMinItemSize:CGSizeMake(45, 45)];
  [m_categoryView setMaxItemSize:CGSizeMake(45, 45)];
  [m_categoryView setMaxNumberOfRows:1];
  [m_categoryView setAutoresizingMask:CPViewWidthSizable];

  [CPBox makeBorder:m_splitView];

  [m_spinnerView setImage:[[PlaceholderManager sharedInstance] spinner]];
  [m_spinnerView setHidden:YES];

  [[CPNotificationCenter defaultCenter] 
    addObserver:self
       selector:@selector(windowWillClose:)
           name:CPWindowWillCloseNotification
         object:_window];

  [self obtainAlbumData];
  if ( FBBasicData && FBBasicData.name ) {
    [_window setTitle:("Facebook - " + FBBasicData.name)];
    [self setProfileImage];
  } else {
    [self obtainUserName];
  }
}

- (void) windowWillClose:(CPNotification)aNotification
{
  if ( m_timer ) {
    [m_timer invalidate];
  }
}

// required because the twitter controller is the file owner of the Cib.
- (void) setDelegate:(id)anObject
{
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
  if (m_next_photos_page_url && [[m_scrollView verticalScroller] floatValue] == 1 ) {
    [m_timer invalidate];
    [m_spinnerView setHidden:NO];
    [PMCMWjsonpWorker workerWithUrl:m_next_photos_page_url
                           delegate:self 
                           selector:@selector(fbUpdatePhotos:)];
  }
}

/*
 * Obtain the users album data
 */
- (void)obtainAlbumData
{
  [m_spinnerView setHidden:NO];
  m_fbAlbumsData = nil;
  // album data
  var urlStr = [CPString stringWithFormat:@"%s/albums?access_token=%s", FBMeBaseUrl,
                         [m_cookieValues objectForKey:"access_token"]];
  [PMCMWjsonpWorker workerWithUrl:urlStr delegate:self 
                         selector:@selector(fbUpdateAlbumData:)];
  // friends data
  var urlStr = [CPString stringWithFormat:@"%s/friends?access_token=%s", FBMeBaseUrl,
                         [m_cookieValues objectForKey:"access_token"]];
  [PMCMWjsonpWorker workerWithUrl:urlStr delegate:self 
                         selector:@selector(fbUpdateAlbumData:)];
}

- (void)fbUpdateAlbumData:(JSObject)data
{
  [m_spinnerView setHidden:YES];
  if ( m_fbAlbumsData ) {
    m_fbAlbumsData = [m_fbAlbumsData arrayByAddingObjectsFromArray:data.data];
  } else {
    m_fbAlbumsData = data.data;
  }
  [m_categoryView setContent:m_fbAlbumsData];
}

/*
 * Obtain the basic information on the FB user. This is for displaying their name
 * in the facebook window.
 */
- (void)obtainUserName
{
  var urlStr = [CPString stringWithFormat:@"%s?access_token=%s", FBMeBaseUrl,
                         [m_cookieValues objectForKey:"access_token"]];
  [PMCMWjsonpWorker workerWithUrl:urlStr delegate:self selector:@selector(fbUpdateUserName:)];
}

- (void)fbUpdateUserName:(JSObject)data
{
  if ( data.name ) {
    FBBasicData = data;
    [_window setTitle:("Facebook - " + FBBasicData.name)];
    [self setProfileImage];
  } else {
    [m_contentName setStringValue:"Not able to access Facebook data"];
    [m_updateButton setEnabled:NO];
  }
}

- (void)setProfileImage
{
  var urlStr = [CPString stringWithFormat:"https://graph.facebook.com/%s/picture", 
                         FBBasicData.id];
  [m_profileImage setHidden:NO];
  [ImageLoaderWorker workerFor:urlStr imageView:m_profileImage];
}

- (void)obtainPhotos:(int)idx
{
  if ( m_fbAlbumsData ) {
    var albumData = m_fbAlbumsData[idx];

    [m_spinnerView setHidden:NO];

    if ( albumData.from ) { 
      // this is an album
      var urlStr = [CPString stringWithFormat:@"%s/%s/photos?access_token=%s", FBBaseGraphUrl,
                             albumData.id, [m_cookieValues objectForKey:"access_token"]];
      [m_contentName setStringValue:[CPString stringWithFormat:"Album %s", 
                                              albumData.name]];
      [PMCMWjsonpWorker workerWithUrl:urlStr delegate:self 
                             selector:@selector(fbUpdatePhotos:)];
    } else {
      // this is a friend
      var urlStr = [CPString stringWithFormat:@"%s/%s/albums?access_token=%s", FBBaseGraphUrl,
                             albumData.id, [m_cookieValues objectForKey:"access_token"]];
      [m_contentName setStringValue:[CPString stringWithFormat:"%s's albums", 
                                              albumData.name]];
      m_fbAlbumsData = nil;
      [m_categoryView setContent:[]];
      [PMCMWjsonpWorker workerWithUrl:urlStr delegate:self 
                             selector:@selector(fbUpdateAlbumData:)];
    }
    [m_photoView setContent:[]];
  }
}

- (void)fbUpdatePhotos:(JSObject)data
{
  var facebookPhotos = [Facebook initWithJSONObjects:data.data];
  if ( data.paging && data.paging.next ) {
    m_next_photos_page_url = data.paging.next;
    [self setupScrollerObserver];
  } else {
    m_next_photos_page_url = nil;
    if ( m_timer ) {
      [m_timer invalidate];
    }
  }
  var content = [[m_photoView content] arrayByAddingObjectsFromArray:facebookPhotos];
  [m_photoView setContent:content];
  [[DragDropManager sharedInstance] moreFacebook:facebookPhotos];
  [m_spinnerView setHidden:YES];
  [m_photoView setSelectionIndexes:[CPIndexSet indexSet]];
}

//
// Button action to retrieve facebook data
//
- (CPAction) doUpdate:(id)sender
{
  [m_spinnerView setHidden:NO];
  [m_photoView setContent:[]];
  [m_categoryView setContent:[]];
  [self obtainAlbumData];
}

//
// The magic of drag and drop
//
- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
  if ( aCollectionView == m_photoView ) {
    var idx_store = [];
    [indices getIndexes:idx_store maxCount:([indices count] + 1) inIndexRange:nil];

    var data = [];
    var facebookObjs = [m_photoView content];
    for (var idx = 0; idx < [idx_store count]; idx++) {
      [data addObject:[facebookObjs[idx_store[idx]] id_str]];
    }
    return [CPKeyedArchiver archivedDataWithRootObject:data];
  } else {
    return nil;
  }
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
  if ( aCollectionView == m_photoView ) {
    return [FacebookDragType];
  } else {
    return nil;
  }
}

- (void)collectionViewDidChangeSelection:(CPCollectionView)aCollectionView
{
  CPLogConsole( "[FBC] something changed" );
  if ( aCollectionView == m_categoryView ) {
    var idx = [[m_categoryView selectionIndexes] lastIndex];
    if ( idx >= 0 && idx < m_fbAlbumsData.length ) {
      [self obtainPhotos:idx];
    }
  }
}

@end

