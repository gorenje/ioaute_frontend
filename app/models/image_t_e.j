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
@implementation ImageTE : ToolElement
{
  CPString m_urlString @accessors(property=imageUrl,readonly);

  CPView mtmp_container;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [ImageElementProperties addToClassOfObject:self];
    [PageElementInputSupport addToClassOfObject:self];

    m_urlString = _json.pic_url;

    [self setRotationFromJson];
    [self setImagePropertiesFromJson];
  }
  return self;
}

- (void)promptDataCameAvailable:(CPString)responseValue
{
  if ( !(m_urlString === responseValue) ) {
    m_urlString = responseValue;
    m_destUrl = responseValue;
    [self updateServer];
    [self generateViewForDocument:mtmp_container withUrl:m_urlString];
  }
}

- (void)generateViewForDocument:(CPView)container
{
  mtmp_container = container;
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

@end

@implementation ImageTE (PropertyHanding)

- (void)setImageUrl:(CPString)aString
{
  if ( m_urlString != aString ) {
    m_urlString = aString;
    [self updateMainViewWithNewImageUrl:m_urlString];
  }
}

@end
