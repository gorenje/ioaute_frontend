@implementation ImageTE : ToolElement
{
  CPString m_urlString @accessors(property=imageUrl,readonly);

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

  [self generateViewForDocument:container withUrl:m_urlString];
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

@end

