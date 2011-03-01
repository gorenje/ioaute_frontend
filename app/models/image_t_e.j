@implementation ImageTE : ToolElement
{
  CPString m_urlString;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [ImageElementProperties addToClassOfObject:self];
    [PageElementInputSupport addToClass:[self class]];
    m_urlString = _json.pic_url;
    [self setImagePropertiesFromJson];
  }
  return self;
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !m_urlString ) {
    m_urlString = [self obtainInput:("Enter the URL of the image, e.g. http:"+
                                     "//www.google.com/images/logos/ps_logo2.png")
                       defaultValue:[PlaceholderManager placeholderImageUrl]];
    m_destUrl = m_urlString;
  }

  if (_mainView) {
    [_mainView removeFromSuperview];
  }
  
  _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleToFit];
  [_mainView setHasShadow:NO];

  [container addSubview:_mainView];
  [ImageLoaderWorker workerFor:m_urlString 
                     imageView:_mainView];
}

- (CGSize)initialSize
{
  return [self initialSizeFromJsonOrDefault:CGSizeMake( 150, 150 )];
}

- (CPImage)toolBoxImage
{
  if ( is_defined(_json.tool_image) ) {
    return [PlaceholderManager imageFor:_json.tool_image];
  } else {
    return [[PlaceholderManager sharedInstance] toolImage];
  }
}

// Required for property handling
- (void)setImageUrl:(CPString)aString
{
  m_urlString = aString;
  [ImageLoaderWorker workerFor:m_urlString imageView:_mainView];
}

- (CPString)getImageUrl
{
  return m_urlString;
}

@end

