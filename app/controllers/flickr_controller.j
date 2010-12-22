
@import <Foundation/CPObject.j>

@implementation FlickrController : CPObject
{
  FlickrPhotoView _photoView;
  NSTextField     _searchTerm;
}

- (void)awakeFromCib
{
  var photoItem = [[CPCollectionViewItem alloc] init];
  [photoItem setView:[[FlickrPhotoCell alloc] initWithFrame:CGRectMake(0, 0, 150, 150)]];

  [_photoView setDelegate:self];
  [_photoView setItemPrototype:photoItem];
  [_photoView setAllowsMultipleSelection:YES];
    
  [_photoView setMinItemSize:CGSizeMake(150, 150)];
  [_photoView setMaxItemSize:CGSizeMake(150, 150)];
  [_photoView setAutoresizingMask:CPViewWidthSizable];
}

//
// Button action to retrieve the tweets
//
- (CPAction) doSearch:(id)sender
{
  var userInput = [_searchTerm stringValue];
    
  if (userInput && userInput !== "") {
    var request = [CPURLRequest requestWithURL:flickrSearchUrl(userInput)];
    [CPJSONPConnection sendRequest:request callback:"jsoncallback" delegate:self];
  }
}

//
// CP URL Request callbacks
//
- (void)connection:(CPJSONPConnection)aConnection didReceiveData:(CPString)data
{
  [_photoView setContent:data.photos.photo];
  [[DragDropManager sharedInstance] moreFlickrImages:data.photos.photo];
  [_photoView setSelectionIndexes:[CPIndexSet indexSet]];
}

- (void)connection:(CPJSONPConnection)aConnection didFailWithError:(CPString)error
{
  alert(error) ;
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
  for (var idx = 0; idx < [idx_store count]; idx++) {
    [data addObject:[[_photoView itemAtIndex:[idx_store[idx]]] flickrPhotoId]];
  }
  CPLogConsole( "[FLICKR PHOTO VIEW] Data: " + data );

  return [CPKeyedArchiver archivedDataWithRootObject:data];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
  CPLogConsole( "[FLICKR PHOTO VIEW] returning drag types");
  return [FlickrDragType];
}

@end
