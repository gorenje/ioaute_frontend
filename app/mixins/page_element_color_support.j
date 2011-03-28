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
 * Mixin for the support of foreground color.
 */
@implementation PageElementColorSupport : MixinHelper
{
  int     m_red;
  int     m_blue;
  int     m_green;
  float   m_alpha;
  CPColor m_color;
}

// assume that the _json object has already been set.
- (void)setColorFromJson 
{
  m_red   = _json.red;
  m_blue  = _json.blue;
  m_green = _json.green;
  m_alpha = _json.alpha;
  m_color = [self createColor];
}

- (void)setColor:(CPColor)aColor
{
  m_color = aColor;
  m_red   = Math.round([aColor redComponent] * 255);
  m_green = Math.round([aColor greenComponent] * 255);
  m_blue  = Math.round([aColor blueComponent] * 255);
  m_alpha = [aColor alphaComponent];
}

- (CPColor)getColor
{
  return m_color;
}

- (CPColor)createColor
{
  if ( typeof(m_red) != "undefined" && typeof(m_green) != "undefined" && 
       typeof(m_blue) != "undefined" && typeof(m_alpha) != "undefined" ) {
    return [CPColor colorWith8BitRed:m_red green:m_green blue:m_blue alpha:m_alpha];
  } else {
    if ( self.m_defaultColor ) {
      return m_defaultColor;
    } else {
      return [CPColor blackColor];
    }
  }
}

//
// State handlers helpers.
//
- (CPArray)colorSupportStateHandlers
{
  return [@selector(getColor), @selector(setColor:)];
}

@end
