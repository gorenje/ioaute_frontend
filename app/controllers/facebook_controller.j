@import <Foundation/CPObject.j>

var FBBasicData = nil,
  FBAlbumsData = nil,
  FBMeBaseUrl = @"https://graph.facebook.com/me",
  FBBaseGraphUrl = @"https://graph.facebook.com";
  
@implementation FacebookController : CPWindowController
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

  var categoryItem = [[CPCollectionViewItem alloc] init];
  [categoryItem setView:[[FacebookCategoryCell alloc] initWithFrame:CGRectMake(0, 0, 45, 45)]];
  [_categoryView setDelegate:self];
  [_categoryView setSelectable:YES];
  [_categoryView setAllowsMultipleSelection:NO];
  [_categoryView setItemPrototype:categoryItem];
  [_categoryView setMinItemSize:CGSizeMake(45, 45)];
  [_categoryView setMaxItemSize:CGSizeMake(45, 45)];
  [_categoryView setMaxNumberOfRows:1];
  [_categoryView setAutoresizingMask:CPViewWidthSizable];
  
  [_spinnerView setImage:[[PlaceholderManager sharedInstance] spinner]];
  [_spinnerView setHidden:YES];

  if ( FBBasicData ) {
    [_window setTitle:("Facebook - " + FBBasicData.name)];
  } else {
    [self obtainUserName];
  }
  if ( !FBAlbumsData ) {
    [self obtainAlbumData];
  } else {
    [_categoryView setContent:FBAlbumsData];
  }

}

/*
 * Obtain the users album data
 */
- (void)obtainAlbumData
{
  [_spinnerView setHidden:NO];
  var urlStr = [CPString stringWithFormat:@"%s/albums?access_token=%s", FBMeBaseUrl,
                         [_cookieValues objectForKey:"access_token"]];
  [PMCMWjsonpWorker workerWithUrl:urlStr delegate:self selector:@selector(fbUpdateAlbumData:)];
}

- (void)fbUpdateAlbumData:(JSObject)data
{
  [_spinnerView setHidden:YES];
  FBAlbumsData = data.data;
  [_categoryView setContent:FBAlbumsData];
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

- (void)obtainPhotos:(int)idx
{
  if ( FBAlbumsData ) {
    var urlStr = [CPString stringWithFormat:@"%s/%s/photos?access_token=%s", FBBaseGraphUrl,
                           FBAlbumsData[idx].id, [_cookieValues objectForKey:"access_token"]];
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
  [_photoView setContent:[]];
  [_categoryView setContent:[]];
  [self obtainAlbumData];
}

//
// The magic of drag and drop
//
- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
  if ( aCollectionView == _photoView ) {
    var idx_store = [];
    [indices getIndexes:idx_store maxCount:([indices count] + 1) inIndexRange:nil];

    var data = [];
    var facebookObjs = [_photoView content];
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
  if ( aCollectionView == _photoView ) {
    return [FacebookDragType];
  } else {
    return nil;
  }
}

- (void)collectionViewDidChangeSelection:(CPCollectionView)aCollectionView
{
  CPLogConsole( "[FBC] something changed" );
  if ( aCollectionView == _categoryView ) {
    var idx = [[_categoryView selectionIndexes] lastIndex];
    if ( idx >= 0 && idx < FBAlbumsData.length ) {
      [_spinnerView setHidden:NO];
      [self obtainPhotos:idx];
    }
  }
}

@end

