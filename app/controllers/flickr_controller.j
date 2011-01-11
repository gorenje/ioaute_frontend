
@import <Foundation/CPObject.j>

@implementation FlickrController : CPObject
{
  @outlet CPCollectionView _photoView;
  @outlet NSTextField      _searchTerm;
  @outlet CPImageView      _spinnerImage;
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
  // trigger content display right away
  [self doSearch:self];
}


//
// Button action to retrieve the tweets
//
- (CPAction) doSearch:(id)sender
{
  var userInput = [_searchTerm stringValue];
    
  if (userInput && userInput !== "") {
    [_spinnerImage setHidden:NO];
    [PMCMWjsonpWorker workerWithUrl:[Flickr searchUrl:userInput] delegate:self 
                           selector:@selector(loadPhotos:) callback:"jsoncallback"];
  }
}

//
// JSONP Request callback
//
- (void)loadPhotos:(JSObject)data
{
  var flickrPhotos = [Flickr initWithJSONObjects:data.photos.photo];
  [_photoView setContent:flickrPhotos];
  [[DragDropManager sharedInstance] moreFlickrImages:flickrPhotos];
  [_photoView setSelectionIndexes:[CPIndexSet indexSet]];
  [_spinnerImage setHidden:YES];
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
