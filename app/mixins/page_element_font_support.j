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
@implementation PageElementFontSupport : GRClassMixin
{
  float    m_fontSize      @accessors(property=fontSize);
  CPString m_fontName      @accessors(property=fontName);
  CPFont   m_fontObj       @accessors(property=font);
  int      m_fontAlignment @accessors(property=textAlignment);
}

- (void)setFontFromJson
{
  m_fontSize  = _json.font_size;
  m_fontName  = _json.font_name;
  m_fontAlignment = [check_for_undefined(_json.font_text_alignment,""+CPLeftTextAlignment) 
                                    intValue];
  // TODO support more features, basically everything that is configurable in CPFont.j
  [self _setFont];
}

- (void)_setFont
{
  if ( !m_fontSize ) m_fontSize = 12;
  if ( m_fontName ) {
    m_fontObj = [CPFont fontWithName:m_fontName size:m_fontSize];
  } else {
    m_fontObj = [CPFont systemFontOfSize:m_fontSize]
  }
}

- (void)setTextAlignment:(int)value
{
  m_fontAlignment = value;
  [_mainView setTextAlignment:m_fontAlignment];
}

- (void)setFontSize:(float)value
{
  m_fontSize = value;
  [self _setFont];
  [_mainView setFont:m_fontObj];
}

- (void)setFontName:(CPString)aName
{
  m_fontName = aName;
  [self _setFont];
  [_mainView setFont:m_fontObj];
}

- (void)setFont:(CPFont)aFont
{
  m_fontSize = [aFont size];
  m_fontName = [aFont familyName];
  m_fontObj  = aFont;
  [_mainView setFont:m_fontObj];
}


//
// State handlers helpers.
//
- (CPArray)fontSupportStateHandlers
{
  return [@selector(font), @selector(setFont:),
          @selector(textAlignment), @selector(setTextAlignment:)];
}

@end
