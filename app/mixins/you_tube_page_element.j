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
@implementation YouTubePageElement : MixinHelper
{
  CPString m_thumbnailUrl @accessors(property=thumbnailImageUrl,readonly);
  CPString m_imageUrl     @accessors(property=largeImageUrl,readonly);
  CPString m_title        @accessors(property=videoTitle,readonly);
  CPString m_owner        @accessors(property=videoOwner,readonly);
  CPString m_video        @accessors(property=videoLink,readonly);

  int m_search_engines    @accessors(property=searchEngines);
  CPString m_artist_name  @accessors(property=artistName);
  CPString m_artist_url   @accessors(property=artistUrl);

  int m_rotation          @accessors(property=rotation,readonly);
  int m_seek_to           @accessors(property=seekTo);
}

- (void)updateFromJson
{
  if ( _json.thumbnail ) {
    m_thumbnailUrl = _json.thumbnail.sqDefault;
    m_imageUrl     = _json.thumbnail.hqDefault;
  }

  if ( _json.content ) {
    m_video        = _json.content["5"]; // 5 is the format.
  }

  if ( is_undefined( m_video ) ) {
    [AlertUserHelper withPageElementError:@"Video formats don't support web integration"];
    [[CPNotificationCenter defaultCenter]
        postNotificationName:PageElementWantsToBeDeletedNotification
                      object:self];
  }

  if ( _json.artist ) {
    m_artist_name    = _json.artist.name;
    m_artist_url     = _json.artist.url;
  } else {
    m_artist_name    = "";
    m_artist_url     = "";
  }

  [self setSearchEngines:[check_for_undefined(_json.m_search_engines, "0") intValue]];

  m_title          = _json.title;
  m_owner          = _json.uploader;
  m_rotation       = [check_for_undefined(_json.rotation, "0") intValue];
  m_seek_to        = [check_for_undefined(_json.m_seek_to, "0") intValue]
}

- (void)removeSearchEngine:(int)srchTag
{
  /*
    Using '&' here because we only subtract if srchTag is set, 
    else we subtract zero.
  */
  m_search_engines -= (m_search_engines & srchTag);
}

- (void)addSearchEngine:(int)srchTag
{
  m_search_engines = (m_search_engines | srchTag);
}

- (void)setRotation:(int)aRotValue
{
  m_rotation = aRotValue;
  if ( [_mainView respondsToSelector:@selector(setRotationDegrees:)] ) {
    [_mainView setRotationDegrees:m_rotation];
  }
}

- (int)videoId
{
  return [page_element_id intValue];
}

@end
