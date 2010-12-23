
@import <Foundation/CPObject.j>

@implementation Flickr : PMDataSource
{
  CPImageView _imageView;
  CPImage     _image;
}

//
// Class method for creating an array of Flickr objects from JSON
//
+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  var objects = [[CPArray alloc] init];
    
  for (var idx = 0; idx < someJSONObjects.length; idx++) {
    [objects addObject:[[Flickr alloc] initWithJSONObject:someJSONObjects[idx]]];
  }
    
  return objects;
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
  [_imageView setImage:anImage];
}

- (void)removeFromSuperview
{
  [_imageView removeFromSuperview];
}

- (void)generateViewForDocument:(CPView)container
{
  if (!_imageView) {
    _imageView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
    [_imageView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [_imageView setImageScaling:CPScaleProportionally];
    [_imageView setHasShadow:YES];
  }

  [container addSubview:_imageView];
    
  if ( _image ) {
    [_image setDelegate:nil];
  }
  _image = [[CPImage alloc] initWithContentsOfFile:[self flickrThumbUrlForPhoto]];
  [_image setDelegate:self];
    
  if([_image loadStatus] == CPImageLoadStatusCompleted)
    [_imageView setImage:image];
  else
    [_imageView setImage:nil];
}

@end
