/*
 * See:
 *   http://code.google.com/apis/youtube/2.0/developers_guide_jsonc.html
 *   http://code.google.com/apis/youtube/2.0/developers_guide_protocol_api_query_parameters.html
 *   
 */
@implementation YouTubeVideo : PageElement
{
  CPString m_thumbnailUrl @accessors(property=thumbnailImageUrl,readonly);
  CPString m_imageUrl @accessors(property=largeImageUrl,readonly);
}

+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PageElement generateObjectsFromJson:someJSONObjects forClass:self];
}

+ (CPString)searchUrlFor:(CPString)aQueryString
{ // q=football+-soccer&orderby=published&start-index=11&max-results=10&v=2&alt=jsonc
  return @"http://gdata.youtube.com/feeds/api/videos?alt=jsonc&orderby=published&v=2&max-results=20&format=5&q=" + encodeURIComponent(aQueryString);
}

+ (CPString)searchUrlNextPage:(JSObject)cursor searchTerm:(CPString)aQueryString
{
  var pages = cursor.pages;
  if ( pages ) {
    var nextPage = pages[cursor.currentPageIndex + 1];
    if ( nextPage ) {
      return nil;
//       return ("http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&q=" + 
//               encodeURIComponent(aQueryString) + "&start=" + nextPage.start );
    }
  }
  return nil;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    m_thumbnailUrl = _json.thumbnail.sqDefault;
    m_imageUrl = _json.thumbnail.hqDefault;
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
  [_mainView setHasShadow:YES];

  [container addSubview:_mainView];
    
  [ImageLoaderWorker workerFor:[self largeImageUrl] imageView:_mainView];
}

@end
