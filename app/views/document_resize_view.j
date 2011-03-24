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
 * DEPRECATED
 * used to show the publication resize slider but is no longer being used.
 */
@implementation DocumentResizeView : CPView
{
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];
    
  var slider = [[CPSlider alloc] initWithFrame:CGRectMake(30, CGRectGetHeight(aFrame)/2.0 - 8, CGRectGetWidth(aFrame) - 65, 24)];

  [slider setMinValue:50.0];
  [slider setMaxValue:250.0];
  [slider setIntValue:150.0];
  [slider setAction:@selector(adjustPublicationZoom:)];
    
  [self addSubview:slider];
                                                             
  var label = [CPTextField flickr_labelWithText:"50"];
  [label setFrameOrigin:CGPointMake(0, CGRectGetHeight(aFrame)/2.0 - 4.0)];
  [self addSubview:label];

  label = [CPTextField flickr_labelWithText:"250"];
  [label setFrameOrigin:CGPointMake(CGRectGetWidth(aFrame) - CGRectGetWidth([label frame]), CGRectGetHeight(aFrame)/2.0 - 4.0)];
  [self addSubview:label];
    
  return self;
}

@end
