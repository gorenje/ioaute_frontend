@implementation Flickr : PageElement
{
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

+ (CPString)searchUrl:(CPString)search_term pageNumber:(int)aPageNumber
{
  return ("http://www.flickr.com/services/rest/?" +
          "method=flickr.photos.search&tags=" + encodeURIComponent(search_term) +
          "&media=photos&machine_tag_mode=any&per_page=20&" +
          "format=json&api_key=8407696a2655de1d93f068d273981f2b&page=" + aPageNumber);
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

- (void)generateViewForDocument:(CPView)container
{
  if (_mainView) {
    [_mainView removeFromSuperview];
  }

  _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleToFit];
  [_mainView setHasShadow:YES];

  [container addSubview:_mainView];
    
  [ImageLoaderWorker workerFor:[self flickrLargeUrlForPhoto] imageView:_mainView];
}

@end
