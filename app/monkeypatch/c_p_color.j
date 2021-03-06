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

+ (CPColor) transparent
{
  return [CPColor colorWithWhite:0 alpha:0];
}

@end
