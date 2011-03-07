/*
 * Beware that this tool element gets converted to a YouTubeVideo Element on the server
 * side and is returned as such. That means reloading the editor will remove this
 * from the document and replace it with a YouTubeVideo element.
 */
@implementation YouTubeTE : ToolElement
{
  CPString m_origUrl;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [YouTubeVideoProperties addToClass:[self class]];
    [YouTubePageElement addToClass:[self class]];
    [PageElementInputSupport addToClass:[self class]];

    m_origUrl = _json.original_url;
    [self updateFromJson];
  }
  return self;
}

- (void)generateViewForDocument:(CPView)container
{
  if ( _mainView ) {
    [_mainView removeFromSuperview];
  }

  _mainView = [[PMImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleToFit];
  [_mainView setHasShadow:NO];
  [_mainView setRotationDegrees:[self rotation]];

  [container addSubview:_mainView];

  if ( m_thumbnailUrl ) {
    [ImageLoaderWorker workerFor:m_thumbnailUrl imageView:_mainView];
  } else {
    [_mainView setImage:[[PlaceholderManager sharedInstance] spinner]];
  }

  if ( !m_origUrl ) {
    m_origUrl = [self obtainInput:("Please YouTube video link, e.g. "+
                                   "http://www.youtube.com/watch?v="+
                                   "WgYbs-DPe5Y&feature=related")
                     defaultValue:"http://www.youtube.com/watch?v=Srmdij0CU1U"];

    var urlString = [YouTubeVideo queryUrlForVideo:m_origUrl];
    if ( urlString ) {
      [PMCMWjsonpWorker workerWithUrl:urlString
                             delegate:self
                             selector:@selector(storeDetails:)
                             callback:"callback"];
    }
  }
}

- (void)havePageElementIdDoAnyUpdate
{
  [self updateServer];
}

- (void) storeDetails:(JSObject)data
{
  _json = data.data;
  [self updateFromJson];
  if ( page_element_id ) [self updateServer];
  [ImageLoaderWorker workerFor:m_thumbnailUrl imageView:_mainView];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolYouTube];
}

@end

