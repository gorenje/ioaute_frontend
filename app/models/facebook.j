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
@implementation Facebook : PageElement
{
  CPString _picUrl     @accessors(property=thumbImageUrl,readonly);
  CPString _srcUrl     @accessors(property=largeImageUrl,readonly);
  CPString _fromUser   @accessors(property=fromUser,readonly);
  CPString _fromUserId;
}

//
// Class method for creating an array of Flickr objects from JSON
//
+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PageElement generateObjectsFromJson:someJSONObjects forClass:self];
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [ImageElementProperties addToClassOfObject:self];
    _picUrl     = _json.picture;
    _srcUrl     = _json.source;
    _fromUser   = _json.from.name;
    _fromUserId = _json.from.id;

    [self setImagePropertiesFromJson];
    [self setDestUrlFromJson:_srcUrl];
  }
  return self;
}

- (CPString) id_str
{
  return _json.id;
}

- (void)generateViewForDocument:(CPView)container
{
  [self generateViewForDocument:container withUrl:[self largeImageUrl]];
}

// Required for property handling
- (void)setImageUrl:(CPString)aString
{
}

- (CPString)imageUrl
{
  return "Set Automagically";
}

@end
