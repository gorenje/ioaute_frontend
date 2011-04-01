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
@implementation PageElementSizeSupport : GRClassMixin

- (void)setSize:(CGSize)aSize
{
  width = aSize.width;
  height = aSize.height;
}

- (void)setFrameSize:(CGSize)aSize
{
  [self setSize:aSize];
  // this gets picked up by the document view cell editor view if there is one for this
  // page element. It resizes everything else. If there isn't a document view editor, then
  // the document is not updated by the server will (probably via a 
  // call to sendResizeToServer).
  [[CPNotificationCenter defaultCenter] 
    postNotificationName:PageElementDidResizeNotification
                  object:self];
}

- (CGSize)getSize
{
  return CGSizeMake(width, height);
}

- (PageElement) setLocation:(CGRect)aLocation
{
  x      = aLocation.origin.x;
  y      = aLocation.origin.y;
  width  = aLocation.size.width;
  height = aLocation.size.height;
  return self;
}

- (CGRect) location
{
  return CGRectMake(x, y, width, height);
}

@end
