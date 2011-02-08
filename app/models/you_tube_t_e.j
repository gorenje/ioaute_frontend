@implementation YouTubeTE : ToolElement
{
  CPString m_origUrl;

  CPString m_thumbnailUrl @accessors(property=thumbnailImageUrl,readonly);
  CPString m_imageUrl     @accessors(property=largeImageUrl,readonly);
  CPString m_title        @accessors(property=videoTitle,readonly);
  CPString m_owner        @accessors(property=videoOwner,readonly);
  CPString m_video;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    m_origUrl      = _json.original_url;
    [self updateFromJson];
  }
  return self;
}

- (void)updateFromJson
{
  if ( _json.thumbnail ) {
    m_thumbnailUrl = _json.thumbnail.sqDefault;
    m_imageUrl     = _json.thumbnail.hqDefault;
  }
  if ( _json.content ) {
    m_video        = _json.content["5"];
  }
  m_title        = _json.title;
  m_owner        = _json.uploader;
}

- (void)generateViewForDocument:(CPView)container
{
  if ( _mainView ) {
    [_mainView removeFromSuperview];
  }

  _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleToFit];
  [_mainView setHasShadow:NO];
  [container addSubview:_mainView];

  if ( m_thumbnailUrl ) {
    [ImageLoaderWorker workerFor:m_thumbnailUrl imageView:_mainView];
  } else {
    [_mainView setImage:[[PlaceholderManager sharedInstance] spinner]];
  }

  if ( !m_origUrl ) {
    m_origUrl = prompt("Please YouTube video link, e.g. "+
                       "http://www.youtube.com/watch?v=WgYbs-DPe5Y&feature=related");
    if ( m_origUrl ) {
      var urlString = [YouTubeVideo queryUrlForVideo:m_origUrl];
      if ( urlString ) {
        [PMCMWjsonpWorker workerWithUrl:urlString
                               delegate:self
                               selector:@selector(storeDetails:)
                               callback:"callback"];
      }
    }
  }
}

- (void) storeDetails:(JSObject)data
{
  _json = data.data;
  [self updateFromJson];
  [self updateServer];
  [ImageLoaderWorker workerFor:m_thumbnailUrl imageView:_mainView];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolYouTube];
}

@end

