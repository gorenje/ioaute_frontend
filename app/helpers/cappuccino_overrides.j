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
 * Store all CIB data on a url-data basis in this dictionary. To prevent cibs from
 * being continously downloaded by the CPWindowController, or rather the CPCib, we
 * override the responsible init method and cache the data.
 */
CibDataCacheDictionary = [CPDictionary dictionary];

@implementation CPCib (CacheDataResponse)

/*
 * The argument, at least in the current application, always seems to be a CPString. 
 * So we can assume that, and append a timestamp to avoid caching problems.
 */
- (id)initWithContentsOfURL:(CPURL)aURL
{
  self = [super init];
  if (self)
  {
    if ( [CibDataCacheDictionary objectForKey:aURL] ) {
      _data = [CPData dataWithRawString:[[CibDataCacheDictionary 
                                           objectForKey:aURL] rawString]];
    } else {
      var request = [CPURLRequest 
                      requestWithURL:[aURL stringByAppendingFormat:"?%s", 
                                           [CPString timestamp]]];
      _data = [CPURLConnection sendSynchronousRequest:request returningResponse:nil];
      [CibDataCacheDictionary setObject:_data forKey:aURL];
    }
    _awakenCustomResources = YES;
  }
  return self;
}
@end

/*
 * Title and tag as init method.
 */
@implementation CPMenuItem (TagAndTitleInit)

+ (id)withTitle:(CPString)aTitle andTag:(int)aTag
{
  self = [[CPMenuItem alloc] initWithTitle:aTitle action:NULL keyEquivalent:nil];
  if ( self ) {
    [self setTag:aTag];
  }
  return self;
}

@end

/*
 * Make the Alert window selectable. I think this doesn't even work.
 */
@implementation CPAlert (MakeSelectable)

- (void) setEnabled:(BOOL)flag
{
  [_messageLabel setEnabled:flag];
}

- (void) setSelectable:(BOOL)flag
{
  [_messageLabel setSelectable:flag];
}

- (void) setEditable:(BOOL)flag
{
  [_messageLabel setEditable:flag];
}

- (void) close
{
  [CPApp abortModal];
  [[self window] close];
}

@end

/*
 * I don't think this is used anywhere but is the intention of having all the rails
 * string helpers collected here.
 */
@implementation CPString (IsBlank)

- (BOOL)isBlank
{
  // TODO this is needs to be done better
  return (self === @"");
}

+ (CPString)timestamp
{
  return [CPString stringWithFormat:"%d", new Date().getTime()];
}
@end

/*
 * From Rails, return any random value from an array.
 */
@implementation CPArray (RandomValueFromArray)

/*
 * Return any object that is currently contained in the array.
 */
- (CPObject)anyValue
{
  var idx = Math.floor(Math.random() * ([self count]+1));
  // idx is [self count] when Math.random() == 1
  return (self[idx] || self[0]);
}

@end

/*
 * Color specification using integer values - 0 to 255.
 */
@implementation CPColor (ColorWithEightBit)

/*
 * Instead of float values, we use integer values from 0 to 255 (incl.) for the RGB
 * components. Alpha remains a float value from 0.0 to 1.0.
 */
+ (CPColor) colorWith8BitRed:(int)red green:(int)green blue:(int)blue alpha:(float)alpha
{
  return [CPColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
}

@end

/*
 * flickr label text
 */
@implementation CPTextField (CreateLabel)

+ (CPTextField)flickr_labelWithText:(CPString)aString
{
  var label = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
    
  [label setStringValue:aString];
  [label sizeToFit];
  [label setTextShadowColor:[CPColor whiteColor]];
  [label setTextShadowOffset:CGSizeMake(0, 1)];
    
  return label;
}

@end

/*
 * Make borders around views.
 */
@implementation CPBox (BorderedBox)

+ (CPBox)makeBorder:(CPView)aView
{
  var box = [CPBox boxEnclosingView:aView];
  [box setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [box setBorderColor:[CPColor colorWithHexString:@"a9aaae"]];
  [box setBorderType:CPLineBorder];
}

@end

/*
 * allow access to the scrollToSelection method from outside.
 */
@implementation CPCollectionView (ScrollToSelection)

- (void)scrollToSelection
{
  [self _scrollToSelection];
}

@end

/*!
  Mainly for text fields that enjoy taking the left mouse as they own and thereby
  not notifying the DocumentViewEditorView of focus.
*/
@implementation LPMultiLineTextField (RightMouseSupport)

- (void)rightMouseDown:(CPEvent)anEvent
{
  [[DocumentViewEditorView sharedInstance] focusOnDocumentViewCell:[self superview]];
}

// TODO use the right mouse to move text page elements but all the following is not
// TODO working since the event is not arriving here.
// See CPWindow.j for the event handling mechanism.
//
// - (void)rightMouseDragged:(CPEvent)anEvent
// {
//   CPLogConsole( "RIGHT Mouse Bragged" );
// }
// - (void)mouseDragged:(CPEvent)anEvent
// {
//   CPLogConsole( "Mouse Bragged" );
//   if ( [anEvent type] == CPRightMouseDragged ) {
//     CPLogConsole( "right mouse drtagger" );
//   } else {
//     return [[[anEvent window] platformWindow] _propagateCurrentDOMEvent:YES];
//   }
// }

@end

@implementation CPCursor (MoreCursors)

+ (CPCursor)resizeSouthEastCursor
{
    return [CPCursor _systemCursorWithName:CPStringFromSelector(_cmd) cssString:@"se-resize" hasImage:NO];
}

@end
