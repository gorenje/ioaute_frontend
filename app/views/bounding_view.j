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
  A view that is constructed from the backingStoreFrame of a CALayer. Its purpose
  in life so to represent a bound around a rotated layer so that we can "extend"
  the view of the rotate element and get clicks and user interaction as if they
  clicked on the element itself.
*/
@implementation BoundingView : CPView
{
  CALayer m_layer;
  id m_delegate;
}

- (id)initWithView:(CPView)aView
{
  self = [super initWithFrame:[[aView layer] backingStoreFrame]];
  if ( self ) {
    m_layer = [aView layer];
    m_delegate = aView;
    [[self window] setAcceptsMouseMovedEvents:YES];
    [self updateView];
  }
  return self;
}

- (CPEvent)correctEventLocation:(CPEvent)anEvent
{
  anEvent._location = [m_layer convertPoint:[anEvent locationInWindow]
                                    toLayer:m_layer];
  return anEvent;
}

- (BOOL)acceptsFirstResponder 
{
  return NO;
}

- (void)mouseEntered:(CPEvent)anEvent
{
  [m_delegate mouseEntered:[self correctEventLocation:anEvent]];
}

- (void)mouseMoved:(CPEvent)anEvent
{
  [m_delegate mouseMoved:[self correctEventLocation:anEvent]];
}

- (void)mouseExited:(CPEvent)anEvent
{
  [m_delegate mouseExited:[self correctEventLocation:anEvent]];
}

- (void)mouseDown:(CPEvent)anEvent
{
  [m_delegate mouseDown:[self correctEventLocation:anEvent]];
}

- (void)mouseUp:(CPEvent)anEvent
{
  [m_delegate mouseUp:[self correctEventLocation:anEvent]];
}

- (void)mouseDragged:(CPEvent)anEvent
{
  [m_delegate mouseDragged:anEvent];
}

/*!
  Something changed, update ourselves.
*/
- (void)updateView
{
  var diffX =  ([m_layer backingStoreFrame].size.width/2)- ([m_delegate frame].size.width/2),
    diffY = ([m_layer backingStoreFrame].size.height/2)- ([m_delegate frame].size.height/2);

  var boundingOrigin = CGPointMake( [m_delegate frameOrigin].x - diffX,
                                    [m_delegate frameOrigin].y - diffY );
  [self setFrame:[m_layer backingStoreFrame]];
  [self setFrameOrigin:boundingOrigin];
}

@end
