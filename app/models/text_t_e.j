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
@implementation TextTE : ToolElement
{
  CPString _textTyped @accessors(property=textTyped);
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementColorSupport addToClassOfObject:self];
    [PageElementFontSupport addToClassOfObject:self];
    [PageElementTextInputSupport addToClassOfObject:self];
    _textTyped = _json.text;
    [self setFontFromJson];
    [self setColorFromJson];
  }
  return self;
}

- (void)generateViewForDocument:(CPView)container
{
  if ( _mainView) {
    [_mainView removeFromSuperview];
  }

  [self _setFont];
  [self setupMainViewAddTo:container];
  if ( _textTyped ) {
    [_mainView setStringValue:_textTyped];
  } else {
    [_mainView setStringValue:@"Type Text Here"];
  }
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolText];
}

@end

@implementation TextTE (PropertyHandling)

- (BOOL) hasProperties
{
  return YES;
}

- (void)openProperyWindow
{
  [[[PropertyTextTEController alloc] initWithWindowCibName:TextTEPropertyWindowCIB 
                                               pageElement:self] showWindow:self];
}

- (void)setTextColor:(CPColor)aColor
{
  [self setColor:aColor];
  [_mainView setTextColor:aColor];
}

@end

@implementation TextTE (StateHandling)

- (CPArray)stateCreators
{
  return [[[self fontSupportStateHandlers] 
           arrayByAddingObjectsFromArray:[self colorSupportStateHandlers]]
           arrayByAddingObjectsFromArray:[@selector(textTyped), @selector(setTextTyped:)]];
}

- (void)postStateRestore
{
  [self revertTextAttributes];
}

@end
