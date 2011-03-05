@implementation Facebook : PageElement
{
  CPString _picUrl     @accessors(property=thumbImageUrl,readonly);
  CPString _srcUrl     @accessors(property=largeImageUrl,readonly);
  CPString _fromUser   @accessors(property=fromUser,readonly);
  CPString _fromUserId;
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
    [ImageElementProperties addToClassOfObject:self];
    _picUrl     = _json.picture;
    _srcUrl     = _json.source;
    _fromUser   = _json.from.name;
    _fromUserId = _json.from.id;

    [self setImagePropertiesFromJson];
    [self setDestUrlFromJson:_srcUrl];
  }
  return self;
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
  [_mainView setHasShadow:NO];

  [container addSubview:_mainView];
    
  [ImageLoaderWorker workerFor:[self largeImageUrl] imageView:_mainView];
}

// Required for property handling
- (void)setImageUrl:(CPString)aString
{
}

- (CPString)imageUrl
{
  return "Set Automagically";
}

@end
