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
@implementation HighlightTE : ToolElement
{
  CPString m_link_url       @accessors(property=linkUrl);
  int m_is_clickable        @accessors(property=clickable);
  int m_show_as_border      @accessors(property=showAsBorder);
  int m_border_width        @accessors(property=borderWidth);

  int m_corner_top_left     @accessors(property=cornerTopLeft);
  int m_corner_top_right    @accessors(property=cornerTopRight);
  int m_corner_bottom_left  @accessors(property=cornerBottomLeft);
  int m_corner_bottom_right @accessors(property=cornerBottomRight);
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementColorSupport addToClassOfObject:self];
    [PageElementRotationSupport addToClassOfObject:self];
    [self setColorFromJson];

    initialSize      = [self initialSizeFromJsonOrDefault:CGSizeMake( 150, 35 )];
    m_link_url       = check_for_undefined(_json.link_url, "");
    m_is_clickable   = [check_for_undefined(_json.clickable, "0" ) intValue];
    m_show_as_border = [check_for_undefined(_json.show_as_border, "0") intValue];
    m_border_width   = [check_for_undefined(_json.border_width, "3") intValue];

    m_corner_top_left     = [check_for_undefined(_json.corner_top_left, "0") intValue];
    m_corner_top_right    = [check_for_undefined(_json.corner_top_right, "0") intValue];
    m_corner_bottom_left  = [check_for_undefined(_json.corner_bottom_left, "0") intValue];
    m_corner_bottom_right = [check_for_undefined(_json.corner_bottom_right, "0") intValue];

    [self setRotationFromJson];
    m_color = [self createColor];
  }
  return self;
}

- (void)generateViewForDocument:(CPView)container
{
  if (_mainView) [_mainView removeFromSuperview];
  
  _mainView = [[PMHighlightView alloc] 
                   initWithFrame:CGRectMakeCopy([container bounds])
                highlightElement:self];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setRotationDegrees:[self rotation]];
  [container addSubview:_mainView];
}

- (CPImage)toolBoxImage
{
  if ( is_undefined(_json.image) ) {
    return [[PlaceholderManager sharedInstance] toolHighlight];
  } else {
    return [PlaceholderManager imageFor:_json.image];
  }
}

- (BOOL)hasRoundedCorners
{
  return ( m_corner_top_left > 0 || m_corner_top_right > 0 ||
           m_corner_bottom_left > 0 || m_corner_bottom_right > 0 );
}

@end

@implementation HighlightTE (PropertyHandling)

- (BOOL) hasProperties
{
  return YES;
}

- (void)openProperyWindow
{
  [[[PropertyHighlightTEController alloc] initWithWindowCibName:HighlightTEPropertyWindowCIB
                                                    pageElement:self] showWindow:self];
}

- (void)redisplay
{
  [_mainView redisplay];
}

@end

@implementation HighlightTE (StateHandling)

- (CPArray)stateCreators
{
  return [ @selector(rotation),          @selector(setRotation:),
           @selector(cornerTopLeft),     @selector(setCornerTopLeft:),
           @selector(cornerTopRight),    @selector(setCornerTopRight:),
           @selector(cornerBottomLeft),  @selector(setCornerBottomLeft:),
           @selector(cornerBottomRight), @selector(setCornerBottomRight:),
           @selector(getColor),          @selector(setColor:),
           @selector(borderWidth),       @selector(setBorderWidth:),
           @selector(clickable),         @selector(setClickable:),
           @selector(showAsBorder),      @selector(setShowAsBorder:),
           @selector(linkUrl),           @selector(setLinkUrl:)];
}

- (void)postStateRestore
{
  [_mainView redisplay];
}

@end
