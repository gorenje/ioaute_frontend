/*
 * Documentation for the API: http://code.google.com/apis/imagesearch/v1/jsondevguide.html
 */
@implementation GoogleImage : PageElement
{
  CPString m_thumbnailUrl @accessors(property=thumbnailImageUrl,readonly);
  CPString m_imageUrl     @accessors(property=imageUrl,readonly);
}

+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PageElement generateObjectsFromJson:someJSONObjects forClass:self];
}

+ (CPString)searchUrlFor:(CPString)aQueryString
{
  return ("http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&q=" + 
          encodeURIComponent(aQueryString));
}

+ (CPString)searchUrlNextPage:(JSObject)cursor searchTerm:(CPString)aQueryString
{
  var pages = cursor.pages;
  if ( pages ) {
    var nextPage = pages[cursor.currentPageIndex + 1];
    if ( nextPage ) {
      return ("http://ajax.googleapis.com/ajax/services/search/images?v=1.0&rsz=8&q=" + 
              encodeURIComponent(aQueryString) + "&start=" + nextPage.start );
    }
  }
  return nil;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [ImageElementProperties addToClassOfObject:self];
    m_thumbnailUrl = _json.unescapedUrl;
    m_imageUrl = _json.unescapedUrl;
    [self setImagePropertiesFromJson];
    [self setDestUrlFromJson:_json.unescapedUrl];
  }
  return self;
}

- (CPString) id_str
{
  return _json.imageId;
}

- (void)generateViewForDocument:(CPView)container
{
  [self generateViewForDocument:container withUrl:[self largeImageUrl]];
}

// Required for property handling
- (void)setImageUrl:(CPString)aString
{
  m_imageUrl = aString;
  [ImageLoaderWorker workerFor:m_imageUrl 
                     imageView:_mainView
                      rotation:[self rotation]];
}

- (CPString)largeImageUrl
{
  return m_imageUrl;
}

@end
