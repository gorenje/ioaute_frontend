
@import <Foundation/CPObject.j>

var FBBasicData = nil,
  FBAlbumsData = nil,
  FBMeBaseUrl = @"https://graph.facebook.com/me",
  FBBaseGraphUrl = @"https://graph.facebook.com";
  
@implementation FacebookController : CPObject
{
  @outlet CPWindow         _window;
  @outlet CPImageView      _spinnerView;
  @outlet CPCollectionView _photoView;
  @outlet CPCollectionView _categoryView;

  CPDictionary _cookieValues;
}

- (void)awakeFromCib
{
  _cookieValues = getQueryVariables([[ConfigurationManager sharedInstance] fbCookie]);

  var photoItem = [[CPCollectionViewItem alloc] init];
  [photoItem setView:[[FacebookPhotoCell alloc] initWithFrame:CGRectMake(0, 0, 150, 150)]];

  [_photoView setDelegate:self];
  [_photoView setItemPrototype:photoItem];
  [_photoView setSelectable:YES];
  [_photoView setAllowsMultipleSelection:YES];
    
  [_photoView setMinItemSize:CGSizeMake(150, 150)];
  [_photoView setMaxItemSize:CGSizeMake(150, 150)];
  [_photoView setAutoresizingMask:CPViewWidthSizable];

  [_spinnerView setImage:[[PlaceholderManager sharedInstance] spinner]];
  [_spinnerView setHidden:YES];

  if ( FBBasicData ) {
    [_window setTitle:("Facebook - " + FBBasicData.name)];
  } else {
    [self obtainUserName];
  }
  if ( !FBAlbumsData ) {
    [self obtainAlbumData];
  }
}

/*
 * Obtain the users album data
 */
- (void)obtainAlbumData
{
  var urlStr = [CPString stringWithFormat:@"%s/albums?access_token=%s", FBMeBaseUrl,
                         [_cookieValues objectForKey:"access_token"]];
  [PMCMWjsonpWorker workerWithUrl:urlStr delegate:self selector:@selector(fbUpdateAlbumData:)];
}

- (void)fbUpdateAlbumData:(JSObject)data
{
  FBAlbumsData = data.data;
}

/*
 * Obtain the basic information on the FB user. This is for displaying their name
 * in the facebook window.
 */
- (void)obtainUserName
{
  var urlStr = [CPString stringWithFormat:@"%s?access_token=%s", FBMeBaseUrl,
                         [_cookieValues objectForKey:"access_token"]];
  [PMCMWjsonpWorker workerWithUrl:urlStr delegate:self selector:@selector(fbUpdateUserName:)];
}

- (void)fbUpdateUserName:(JSObject)data
{
  FBBasicData = data;
  [_window setTitle:("Facebook - " + FBBasicData.name)];
}

- (void)obtainPhotos
{
  if ( FBAlbumsData ) {
    var urlStr = [CPString stringWithFormat:@"%s/%s/photos?access_token=%s", FBBaseGraphUrl,
                           FBAlbumsData[0].id, [_cookieValues objectForKey:"access_token"]];
    [PMCMWjsonpWorker workerWithUrl:urlStr delegate:self selector:@selector(fbUpdatePhotos:)];
  }
}

- (void)fbUpdatePhotos:(JSObject)data
{
  var facebookPhotos = [Facebook initWithJSONObjects:data.data];
  [_photoView setContent:facebookPhotos];
  [[DragDropManager sharedInstance] moreFacebook:facebookPhotos];
  [_spinnerView setHidden:YES];
  [_photoView setSelectionIndexes:[CPIndexSet indexSet]];
}

//
// Button action to retrieve facebook data
//
- (CPAction) doUpdate:(id)sender
{
  [_spinnerView setHidden:NO];
  [self obtainPhotos];
}

//
// The magic of drag and drop
//
- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
  var idx_store = [];
  [indices getIndexes:idx_store maxCount:([indices count] + 1) inIndexRange:nil];

  var data = [];
  var facebookObjs = [_photoView content];
  for (var idx = 0; idx < [idx_store count]; idx++) {
    [data addObject:[facebookObjs[idx_store[idx]] id_str]];
  }
  return [CPKeyedArchiver archivedDataWithRootObject:data];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
  return [FacebookDragType];
}

@end

