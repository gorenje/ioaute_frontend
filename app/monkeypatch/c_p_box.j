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
