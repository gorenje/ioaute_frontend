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
