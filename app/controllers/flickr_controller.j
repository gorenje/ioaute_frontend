
@import <Foundation/CPObject.j>

@implementation FlickrController : CPObject
{
  NSCollectionView _photoView;
  NSTextField      _searchTerm;
  CPArray          _images;
}

- (void)awakeFromCib
{
  // This is called when the application is done loading.
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
    // TODO: replace API key in the URL Request -- the api_key is stolen ....
    //create a new request for the photos with the tag returned from the javascript prompt
    var request = [CPURLRequest requestWithURL:"http://www.flickr.com/services/rest/?"+
                                "method=flickr.photos.search&tags="+encodeURIComponent(userInput)+
                                "&media=photos&machine_tag_mode=any&per_page=20&"+
                                "format=json&api_key=ca4dd89d3dfaeaf075144c3fdec76756"];
    
    // see important note about CPJSONPConnection above
    [CPJSONPConnection sendRequest:request callback:"jsoncallback" delegate:self];
  }
}

//
// CP URL Request callbacks
//
- (void)connection:(CPJSONPConnection)aConnection didReceiveData:(CPString)data
{
  [_photoView setContent:data.photos.photo];
  [_photoView setSelectionIndexes:[CPIndexSet indexSet]];
}

- (void)connection:(CPJSONPConnection)aConnection didFailWithError:(CPString)error
{
  alert(error) ;
}

@end
