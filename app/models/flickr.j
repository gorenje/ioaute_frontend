@implementation Flickr : PageElement
{
  CPImage     _image;
  CPImageView _imgView;

  CPString _secret;
  CPString _farm;
  CPString _server;
  CPString _title;
}

//
// Class method for creating an array of Flickr objects from JSON
//
+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PageElement generateObjectsFromJson:someJSONObjects forClass:self];
}

+ (CPString)searchUrl:(CPString)search_term
{
  return ("http://www.flickr.com/services/rest/?" +
          "method=flickr.photos.search&tags=" + encodeURIComponent(search_term) +
          "&media=photos&machine_tag_mode=any&per_page=20&" +
          "format=json&api_key=8407696a2655de1d93f068d273981f2b");
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    _secret = _json.secret;
    _farm   = _json.farm;
    _server = _json.server;
    _title  = _json.title;
  }
  return self;
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

- (CPString) id_str
{
  return _json.id;
}

- (void)imageDidLoad:(CPImage)anImage
{
  [_imgView setImage:anImage];
}

- (void)generateViewForDocument:(CPView)container
{
  if (_mainView) {
    [_mainView removeFromSuperview];
  }

  _imgView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_imgView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_imgView setImageScaling:CPScaleToFit];
  [_imgView setHasShadow:YES];

  _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView addSubview:_imgView];

  [_imgView setFrameOrigin:CGPointMake(0,0)];

  [container addSubview:_mainView];
    
  if ( _image ) {
    [_image setDelegate:nil];
  }
  _image = [[CPImage alloc] initWithContentsOfFile:[self flickrLargeUrlForPhoto]];
  [_image setDelegate:self];
  if ([_image loadStatus] != CPImageLoadStatusCompleted) {
    [_imgView setImage:[[PlaceholderManager sharedInstance] spinner]];
  }
}

@end
