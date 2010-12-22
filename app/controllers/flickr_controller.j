
@import <Foundation/CPObject.j>

@implementation FlickrController : CPObject
{
  FlickrPhotoView _photoView;
  NSTextField     _searchTerm;
  CPArray         _images;
}

- (void)awakeFromCib
{
  _images = [CPArray arrayWithObjects:nil];

  var photoItem = [[CPCollectionViewItem alloc] init];
  [photoItem setView:[[FlickrPhotoCell alloc] initWithFrame:CGRectMake(0, 0, 150, 150)]];

  [_photoView setDelegate:self];
  [_photoView setItemPrototype:photoItem];
    
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

@end
