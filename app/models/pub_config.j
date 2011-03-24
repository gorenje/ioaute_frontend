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
/*!
  Wrapper around the publication configuration sent via json from the server.
*/
@implementation PubConfig : CPObject
{
  JSObject _json;

  CPString m_continous       @accessors(property=continous);
  CPString m_has_shadow      @accessors(property=shadow);
  CPView   m_page_bg_view    @accessors(property=pubBgView);
  CPString m_name            @accessors(property=pubName);
  int      m_snap_grid_width @accessors(property=snapGridWidth,readonly);
  BOOL     m_show_tool_tips  @accessors(property=showToolTips);
}

- (id)init
{
  self = [super init];
  if ( self ) {
    [PageElementColorSupport addToClassOfObject:self];
    [ObjectStateSupport addToClassOfObject:self];
    m_continous       = "0";
    m_has_shadow      = "1";
    m_snap_grid_width = "0";
    m_page_bg_view    = nil;
    m_name            = "";
    m_show_tool_tips  = YES;
  }
  return self;
}

- (void)setBgColor:(CPColor)aColor
{
  [self setColor:aColor];
  if ( m_page_bg_view ) [m_page_bg_view setBackgroundColor:aColor];
}

- (void)setSnapGridWidth:(int)value
{
  m_snap_grid_width = value;
  if ( m_snap_grid_width > 0 ) {
    [DocumentViewCellWithSnapgrid addToClass:DocumentViewCell];
  } else {
    [DocumentViewCellWithoutSnapgrid addToClass:DocumentViewCell];
  }
}

- (void)setShadow:(CPString)aShadowValue
{
  m_has_shadow = aShadowValue;
  var shadowView = [[DocumentViewController sharedInstance] shadowView];
  if ( shadowView ) [shadowView setHidden:![self hasShadow]];
}

- (BOOL) isContinous
{
  return ([m_continous intValue] == 1);
}

- (BOOL) hasShadow
{
  return ([m_has_shadow intValue] == 1);
}

- (void) setConfig:(JSObject)pubConfig
{
  _json = pubConfig.color;
  [self setColorFromJson];
  m_continous       = pubConfig.continous;
  m_name            = pubConfig.name;

  [self setSnapGridWidth:[pubConfig.snap_grid_width intValue]];
  [self setShadow:pubConfig.shadow];
  [self setBgColor:[self getColor]];
}

- (void)requestCompleted:(JSObject)data
{
  switch ( data.action ) {
  case "publications_update":
    if ( data.status == "ok" ) {
      [self setConfig:data.data];
    }
  }
}

@end

@implementation PubConfig (StateHandling)

- (CPArray)stateCreators
{
  return [@selector(continous),     @selector(setContinous:),
          @selector(shadow),        @selector(setShadow:),
          @selector(pubName),       @selector(setPubName:),
          @selector(getColor),      @selector(setBgColor:),
          @selector(snapGridWidth), @selector(setSnapGridWidth:),
          @selector(showToolTips),  @selector(setShowToolTips:)];
}

- (void)postStateRestore
{
}

@end
