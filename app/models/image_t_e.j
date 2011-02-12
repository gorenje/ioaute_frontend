@implementation ImageTE : ToolElement
{
  CPString m_urlString;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [ImageElementProperties addToClassOfObject:self];
    m_urlString = _json.pic_url;
    m_destUrl   = _json.dest_url;
  }
  return self;
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !m_urlString ) {
    // Ignore the value of the urlString, if it's not an image or something else (i.e. 
    // cancel) then a spinner will be shown. This can then be removed from the document.
    m_urlString = prompt("Enter the URL of the image");
    if ( !m_urlString ) {
      m_urlString = [PlaceholderManager placeholderImageUrl];
    }
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
  [ImageLoaderWorker workerFor:m_urlString imageView:_mainView];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolImage];
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

