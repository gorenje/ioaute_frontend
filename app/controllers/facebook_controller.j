
@import <Foundation/CPObject.j>

var FBBasicData = nil;

@implementation FacebookController : CPObject
{
  @outlet NSTextField      _userNameField;
  @outlet CPImageView      _spinnerImage;
  @outlet CPCollectionView _collectionView;

  CPDictionary _cookieValues;
}

- (void)awakeFromCib
{
  _cookieValues = getQueryVariables([[ConfigurationManager sharedInstance] fbCookie]);

  var photoItem = [[CPCollectionViewItem alloc] init];
  [photoItem setView:[[FacebookPhotoCell alloc] initWithFrame:CGRectMake(0, 0, 150, 150)]];

  [_collectionView setDelegate:self];
  [_collectionView setItemPrototype:photoItem];
  [_collectionView setAllowsMultipleSelection:YES];
    
  [_collectionView setMinItemSize:CGSizeMake(150, 150)];
  [_collectionView setMaxItemSize:CGSizeMake(150, 150)];
  [_collectionView setAutoresizingMask:CPViewWidthSizable];

  if ( FBBasicData ) {
    [_userNameField setStringValue:FBBasicData.name];
  } else {
    [self fbUserName];
  }
}


- (void)fbUserName
{
  var urlStr = [CPString stringWithFormat:@"https://graph.facebook.com/me?access_token=%s",
                         [_cookieValues objectForKey:"access_token"]];
  [FBRequestWorker workerWithUrl:urlStr delegate:self selector:@selector(fbUpdateUserName:)];
}

- (void)fbUpdateUserName:(JSObject)data
{
  FBBasicData = data;
  [_userNameField setStringValue:data.name];
}

//
// Button action to retrieve the tweets
//
- (CPAction) doUpdate:(id)sender
{
}

//
// The magic of drag and drop
//
- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
  CPLogConsole( "[FACEBOOK PHOTO VIEW] preparing data for drag");
  var idx_store = [];
  [indices getIndexes:idx_store maxCount:([indices count] + 1) inIndexRange:nil];

  var data = [];
  var flickrObjs = [_collectionView content];
  for (var idx = 0; idx < [idx_store count]; idx++) {
    [data addObject:[flickrObjs[idx_store[idx]] id_str]];
  }
  CPLogConsole( "[FLICKR PHOTO VIEW] Data: " + data );

  return [CPKeyedArchiver archivedDataWithRootObject:data];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
  return [FacebookDragType];
}

@end

@implementation FBRequestWorker : CPObject 
{
  CPString _urlStr;
  id       _delegate;
  SEL      _selector;
}

+ (FBRequestWorker) workerWithUrl:(CPString)url delegate:(id)aDelegate selector:(SEL)aSelector
{
  return [[FBRequestWorker alloc] initWithUrl:url delegate:aDelegate selector:aSelector];
}

- (id) initWithUrl:(CPString)url delegate:(id)aDelegate selector:(SEL)aSelector
{
  _urlStr = url;
  _delegate = aDelegate;
  _selector = aSelector;
  [CPJSONPConnection connectionWithRequest:[CPURLRequest requestWithURL:_urlStr] 
                                  callback:"callback" delegate:self];
}

- (void)connection:(CPJSONPConnection)aConnection didReceiveData:(JSObject)data
{
  CPLogConsole( "[FBWorker] Got data: " + data );
  if ( _delegate && _selector && data ) {
    [_delegate performSelector:_selector withObject:data];
  }
}

- (void)connection:(CPJSONPConnection)aConnection didFailWithError:(CPString)error
{
  alert(error) ;
}

@end
