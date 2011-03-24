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
@implementation PageNumberView : CPCollectionView

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];
  if ( self ) {
    [self registerForDraggedTypes:[PageNumberDragType]];
  }
  return self;
}

- (void)performDragOperation:(CPDraggingInfo)aSender
{
}

// Return the index of the page that is closest to the current dragging location
- (int)indexAtLocation:(CGPoint)aDraggingLocation
{
  var aLocation = [self convertPoint:aDraggingLocation
                            fromView:[[[CPApplication sharedApplication] mainWindow] 
                                       contentView]];
  var allPages = [self content];
  for ( var idx = 0; idx < [allPages count]; idx++ ) {
    if ( CGRectContainsPoint( [self rectForItemAtIndex:idx], aLocation ) ) {
      return idx;
    }
  }
  return -1;
}

@end
