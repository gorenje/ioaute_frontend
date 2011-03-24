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
@implementation LinkTE : ToolElement
{
  CPString m_urlString;
  CPString m_linkTitle @accessors(property=textTyped);
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementColorSupport addToClassOfObject:self];
    [PageElementFontSupport addToClassOfObject:self];
    [PageElementInputSupport addToClassOfObject:self];
    [PageElementTextInputSupport addToClassOfObject:self];

    m_urlString = _json.url;
    m_linkTitle = _json.title;
    [self setColorFromJson];
    [self setFontFromJson];
  }
  return self;
}

- (void)promptDataCameAvailable:(CPString)responseValue
{
  if ( !(m_urlString === responseValue) ) {
    m_urlString = responseValue;
    m_linkTitle = responseValue;
    [self updateServer];
    [_mainView setStringValue:m_linkTitle];
  }
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !m_urlString ) {
    m_urlString = [self obtainInput:"Please enter link:" defaultValue:"http://bit.ly"];
    m_linkTitle = m_urlString;
  }
  
  if ( _mainView ) {
    [_mainView removeFromSuperview];
  }

  [self _setFont];
  [self setupMainViewAddTo:container];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolLink];
}

- (CGSize) initialSize
{
  return [self initialSizeFromJsonOrDefault:CGSizeMake( 150, 33.5 )];
}

@end

// ---------------------------------------------------------------------------------------
@implementation LinkTE (PropertyHandling)

- (BOOL) hasProperties
{
  return YES;
}

- (void)openProperyWindow
{
  [[[PropertyLinkTEController alloc] initWithWindowCibName:LinkTEPropertyWindowCIB 
                                               pageElement:self] showWindow:self];
}

//
// Setters
//
- (void) setLinkColor:(CPColor)aColor
{
  [self setColor:aColor];
  [_mainView setTextColor:aColor];
}

- (void) setLinkTitle:(id)aValue
{
  m_linkTitle = aValue;
  [_mainView setStringValue:[CPString stringWithFormat:"%s", m_linkTitle]];
}

- (void)setLinkDestination:(CPString)urlDestination
{
  m_urlString = urlDestination;
}

//
// Getters
//
- (CPString)getDestination
{
  return m_urlString;
}

- (CPString)getLinkTitle
{
  return m_linkTitle;
}

@end
