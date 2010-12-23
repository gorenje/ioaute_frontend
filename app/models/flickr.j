
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

- (CPString)flickrThumbUrlForPhoto
{
  return ("http://farm" + _json.farm + ".static.flickr.com/" + _json.server + 
          "/" + _json.id + "_" + _json.secret + "_m.jpg");
}

- (CPString) fromUser
{
  return _json.owner;
}

- (CPString) id_str
{
  return _json.id;
}

/*
 * Required for flickr
 */
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
  }

  [container addSubview:_mainView];
    
  if ( _image ) {
    [_image setDelegate:nil];
  }
  _image = [[CPImage alloc] initWithContentsOfFile:[self flickrThumbUrlForPhoto]];
  [_image setDelegate:self];
    
  if([_image loadStatus] == CPImageLoadStatusCompleted)
    [_mainView setImage:image];
  else
    [_mainView setImage:nil];
}

@end
