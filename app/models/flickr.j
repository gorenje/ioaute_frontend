
@import <Foundation/CPObject.j>

@implementation Flickr : PMDataSource
{
  CPImage     _image;
}

//
// Class method for creating an array of Flickr objects from JSON
//
+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PMDataSource generateObjectsFromJson:someJSONObjects forClass:self];
}

- (CPString)flickrUrlForSize:(CPString)sze_str
{
  return ("http://farm" + _json.farm + ".static.flickr.com/" + _json.server + 
          "/" + _json.id + "_" + _json.secret + "_" + sze_str + ".jpg");
}

- (CPString)flickrThumbUrlForPhoto
{
  return [self flickrUrlForSize:@"m"];
}

- (CPString)flickrLargeUrlForPhoto
{
  return [self flickrUrlForSize:@"b"];
}

- (CPString) fromUser
{
  return _json.owner;
}

- (CPString) id_str
{
  return _json.id;
}

- (void)imageDidLoad:(CPImage)anImage
{
  [_mainView setImage:anImage];
}

- (void)generateViewForDocument:(CPView)container
{
  if (!_mainView) {
    _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
    [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [_mainView setImageScaling:CPScaleProportionally];
    [_mainView setHasShadow:YES];
    // TODO need to added copyright notice + reference to the original @ flickr
    // TODO this should a matter of ... hm ... who knows!
    // TODO but can be done as with the twitter view and more subviews into the _mainView.
  }

  [container addSubview:_mainView];
    
  if ( _image ) {
    [_image setDelegate:nil];
  }
  // TODO use full size picture here -- better for resize even if worse for performace
  _image = [[CPImage alloc] initWithContentsOfFile:[self flickrLargeUrlForPhoto]];
  [_image setDelegate:self];
    
  if([_image loadStatus] == CPImageLoadStatusCompleted)
    [_mainView setImage:image];
  else
    [_mainView setImage:[[PlaceholderManager sharedInstance] spinner]];
}

@end
