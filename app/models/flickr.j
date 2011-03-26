/*
 * Created by Gerrit Riessen
 * Copyright 2010-2011, Gerrit Riessen
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
var FlickrBaseUrl = ("http://www.flickr.com/services/rest/?method=%s&" +
                     "format=json&api_key=%s&");
var FlickrBaseUrlPaging = (FlickrBaseUrl + "page=%d&per_page=20&%s");

@implementation Flickr : PageElement
{
  CPString _secret;
  CPString _farm;
  CPString _server;
  CPString _title;
}

+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PageElement generateObjectsFromJson:someJSONObjects forClass:self];
}

//
// Class method for creating an array of Flickr objects from JSON. This is event based 
// because if we look for the photos of a username, then we need to first retrieve the
// 'NSID' from flickr for that user name. Hence this calls the selector (mostly immediately)
// on the specified delegate when the url to load the photos, is ready.
//
+ (void)searchUrl:(CPString)search_term 
       pageNumber:(int)aPageNumber
         delegate:(id)aDelegate
         selector:(SEL)aSelector
{
  if ( [search_term hasPrefix:@"@"] ) {
    // user search, first obtain the NSID for the user.
    [FlickrSearchUrlNotifierWorker workerWithUserName:[search_term substringFromIndex:1]
                                           pageNumber:aPageNumber
                                             delegate:aDelegate
                                             selector:aSelector];
  } else {
    var method = "", restOptions = "";

    if ( [search_term hasPrefix:@"#"] ) {
      // Tag list, so we remove the leading # and pass in the comma separated list of tags
      search_term = [[search_term stringByReplacingOccurrencesOfString:" " withString:","]
                      substringFromIndex:1];
      method = @"flickr.photos.search";
      restOptions = ("tags=" + encodeURIComponent(search_term) + 
                     "&media=photos&machine_tag_mode=any");
    } else if ( [search_term hasPrefix:@"."] ) {
      method = @"flickr.people.getPublicPhotos";
      restOptions = "user_id=" + encodeURIComponent([search_term substringFromIndex:1]);
    } else {
      // free form search
      method = @"flickr.photos.search";
      restOptions = ("text=" + encodeURIComponent(search_term) + "&media=photos");
    }

    [aDelegate performSelector:aSelector 
                    withObject:[CPString stringWithFormat:FlickrBaseUrlPaging, 
                                         method,
                                         [[ConfigurationManager sharedInstance] flickrApiKey],
                                         aPageNumber,restOptions]];
  }
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [ImageElementProperties addToClassOfObject:self];
    [PageElementRotationSupport addToClassOfObject:self];
    _secret = _json.secret;
    _farm   = _json.farm;
    _server = _json.server;
    _title  = _json.title;

    [self setRotationFromJson];
    [self setImagePropertiesFromJson];
    [self setDestUrlFromJson:("http://flickr.com/photo.gne?id=" + [self id_str])];
  }
  return self;
}

- (CPString)flickrUrlForSize:(CPString)sze_str
{
  return ("http://farm" + _json.farm + ".static.flickr.com/" + _json.server + 
          "/" + _json.id + "_" + _json.secret + "_" + sze_str + ".jpg");
}

- (CPString)flickrThumbUrlForPhoto
{
  return [self flickrUrlForSize:@"m"];
}

- (CPString)flickrLargeUrlForPhoto
{
  return [self flickrUrlForSize:@"b"];
}

- (CPString) id_str
{
  return _json.id;
}

- (void)generateViewForDocument:(CPView)container
{
  [self generateViewForDocument:container withUrl:[self flickrLargeUrlForPhoto]];
}

// Required for property handling
- (void)setImageUrl:(CPString)aString
{
}

- (CPString)imageUrl
{
  return @"Set Automagically";
}

@end

// A helper to retrieve the NSID from flickr for a username. This is a real pain in the ass
// but since flickr is too stupid to allow a username as user_id value, we have to do this
// extra call.
@implementation FlickrSearchUrlNotifierWorker : CPObject
{
  id  m_delegate;
  SEL m_selector;
  int m_pageNumber;
}

+ (id)workerWithUserName:(CPString)flickrUserName
              pageNumber:(int)aPageNumber
                delegate:(id)aDelegate
                selector:(SEL)aSelector
{
  return [[FlickrSearchUrlNotifierWorker alloc] initWithUserName:flickrUserName
                                                      pageNumber:aPageNumber
                                                        delegate:aDelegate
                                                        selector:aSelector];
}

- (id)initWithUserName:(CPString)aUserName 
              pageNumber:(int)aPageNumber
              delegate:(id)aDelegate 
              selector:(SEL)aSelector
{
  self = [super init];
  if ( self ) {
    m_pageNumber = aPageNumber;
    m_delegate   = aDelegate;
    m_selector   = aSelector;
    [self obtainNsidForUsername:aUserName];
  }
  return self;
}

- (void)obtainNsidForUsername:(CPString)aUserName
{
  var urlString = ([CPString stringWithFormat:FlickrBaseUrl, 
                             "flickr.people.findByUsername",
                             [[ConfigurationManager sharedInstance] flickrApiKey]] +
                   "username=" + encodeURIComponent(aUserName) );
  [PMCMWjsonpWorker workerWithUrl:urlString
                         delegate:self
                         selector:@selector(gotNsid:) 
                         callback:"jsoncallback"];
}

- (void)gotNsid:(JSObject)data
{
  var urlString = nil;
  if ( data.user ) {
    method = @"flickr.people.getPublicPhotos";
    restOptions = "user_id=" + encodeURIComponent(data.user.nsid);
    urlString = [CPString stringWithFormat:FlickrBaseUrlPaging, 
                          method, [[ConfigurationManager sharedInstance] flickrApiKey],
                          m_pageNumber, restOptions];
  }
  [m_delegate performSelector:m_selector withObject:urlString];
}

@end
