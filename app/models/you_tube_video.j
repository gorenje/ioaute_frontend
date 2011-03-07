/*
 * See:
 *   http://code.google.com/apis/youtube/2.0/developers_guide_jsonc.html
 *   http://code.google.com/apis/youtube/2.0/developers_guide_protocol_api_query_parameters.html
 *   http://911-need-code-help.blogspot.com/2010/01/retrieve-youtube-video-title.html
 */

var ResultsPerPage = 20;
var BaseYouTubeQueryUrl = ("http://gdata.youtube.com/feeds/api/videos?alt=jsonc&"+
                           "orderby=published&v=2&%s&%s");

var BaseQueryUrl = "http://gdata.youtube.com/feeds/api/videos/%s?v=2&alt=jsonc";

@implementation YouTubeVideo : PageElement
{
}

+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PageElement generateObjectsFromJson:someJSONObjects forClass:self];
}

+ (CPString)queryUrlForVideo:(CPString)aVideoUrl
{
  var video_id = getVideoIdFromYouTubeUrl(aVideoUrl);
  if ( video_id ) {
    return [CPString stringWithFormat:BaseQueryUrl, video_id];
  } else {
    return nil;
  }
}

+ (CPString)searchUrlFor:(CPString)aQueryString pageNumber:(int)aPageNumber
{
  var pageSpecs = [CPString stringWithFormat:"max-results=%d&start-index=%d",
                            ResultsPerPage, (ResultsPerPage * aPageNumber) + 1];

  var querySpecs = "q=" + encodeURIComponent(aQueryString);
  if ( [aQueryString hasPrefix:@"@"] ) {
    var space_range = [aQueryString rangeOfString:@" "];
    if ( space_range.location > 0 ) {
      var author_range = CPMakeRange(1, space_range.location-1);
      querySpecs = [CPString stringWithFormat:"author=%s&q=%s",
                             [aQueryString substringWithRange:author_range],
                             [aQueryString substringFromIndex:space_range.location+1]];
                             
    } else {
      querySpecs = "author=" + encodeURIComponent([aQueryString substringFromIndex:1]);
    }
  }

  return [CPString stringWithFormat:BaseYouTubeQueryUrl, pageSpecs, querySpecs];
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [YouTubeVideoProperties addToClass:[self class]];
    [YouTubePageElement addToClass:[self class]];
    [self updateFromJson];
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

  _mainView = [[PMImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleToFit];
  [_mainView setHasShadow:NO];
  [ImageLoaderWorker workerFor:[self largeImageUrl] 
                     imageView:_mainView
                      rotation:[self rotation]];
  [container addSubview:_mainView];
}

@end
