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
@implementation YouTubeSeekToLinkTE : ToolElement
{
  CPString m_textTyped @accessors(property=textTyped);
  CPString m_video_id  @accessors(property=videoId);
  int m_start_at_secs  @accessors(property=startAt);
  int m_end_at_secs    @accessors(property=endAt);
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementColorSupport addToClassOfObject:self];
    [PageElementFontSupport addToClassOfObject:self];
    [PageElementTextInputSupport addToClassOfObject:self];

    m_textTyped     = _json.text;
    m_start_at_secs = [check_for_undefined(_json.start_at_secs, "0") intValue];
    m_end_at_secs   = [check_for_undefined(_json.end_at_secs, "0") intValue];
    m_video_id      = check_for_undefined(_json.video_id, nil);
    [self setFontFromJson];
    [self setColorFromJson];
  }
  return self;
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !m_textTyped  ) {
    m_textTyped = "Enter Text Here";
  }

  if ( _mainView ) {
    [_mainView removeFromSuperview];
  }

  [self _setFont];
  [self setupMainViewAddTo:container];
}

- (CPImage)toolBoxImage
{
  if ( is_defined(_json.tool_image) ) {
    return [PlaceholderManager imageFor:_json.tool_image];
  } else {
    return [[PlaceholderManager sharedInstance] toolYouTube];
  }
}

@end

@implementation YouTubeSeekToLinkTE (PropertyHandling)

- (BOOL) hasProperties
{
  return YES;
}

- (void)openProperyWindow
{
  [[[PropertyYouTubeSeekToLinkTEController alloc]
     initWithWindowCibName:YouTubeSeekToLinkTEPropertyWindowCIB
               pageElement:self] showWindow:self];
}

- (void)setTextColor:(CPColor)aColor
{
  [self setColor:aColor];
  [_mainView setTextColor:aColor];
}

- (void) setLinkText:(CPString)aStringValue
{
  m_textTyped = aStringValue;
  [_mainView setStringValue:m_textTyped];
}

@end
