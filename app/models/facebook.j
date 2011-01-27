@implementation Facebook : PageElement
{
  CPString _picUrl;
  CPString _srcUrl;
  CPString _fromUser;
}

//
// Class method for creating an array of Flickr objects from JSON
//
+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PageElement generateObjectsFromJson:someJSONObjects forClass:self];
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    _picUrl   = _json.picture;
    _srcUrl   = _json.source;
    _fromUser = _json.from.name;
  }
  return self;
}

- (CPString)thumbImageUrl
{
  return _json.picture;
}

- (CPString)largeImageUrl
{
  return _json.source;
}

- (CPString) fromUser
{
  return _json.from.name;
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
    
  [ImageLoaderWorker workerFor:[self largeImageUrl] imageView:_mainView];
}

@end
