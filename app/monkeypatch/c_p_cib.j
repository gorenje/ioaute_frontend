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
 * Store all CIB data on a url-data basis in this dictionary. To prevent cibs from
 * being continously downloaded by the CPWindowController, or rather the CPCib, we
 * override the responsible init method and cache the data.
 */
CibDataCacheDictionary = [CPDictionary dictionary];

@implementation CPCib (CacheDataResponse)

/*
 * The argument, at least in the current application, always seems to be a CPString. 
 * So we can assume that, and append a timestamp to avoid caching problems.
 */
- (id)initWithContentsOfURL:(CPURL)aURL
{
  self = [super init];
  if (self)
  {
    if ( [CibDataCacheDictionary objectForKey:aURL] ) {
      _data = [CPData dataWithRawString:[[CibDataCacheDictionary 
                                           objectForKey:aURL] rawString]];
    } else {
      var request = [CPURLRequest 
                      requestWithURL:[aURL stringByAppendingFormat:"?%s", 
                                           [CPString timestamp]]];
      _data = [CPURLConnection sendSynchronousRequest:request returningResponse:nil];
      [CibDataCacheDictionary setObject:_data forKey:aURL];
    }
    _awakenCustomResources = YES;
  }
  return self;
}
@end
