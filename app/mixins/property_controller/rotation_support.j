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
@implementation PropertyControllerRotationSupport : GRClassMixin
{
  @outlet CPSlider    m_rotationSlider;
  @outlet CPTextField m_rotationValue;
  @outlet CPView      m_rotationView;
  @outlet CPButton    m_flipButton;
}

/*
  TODO: no need to pass in the pageElement, we can assume that 
  TODO: m_pageElement is defined.
*/
- (void)awakeFromCibSetupRotationFields:(PageElement)aPageElement
{
  [CPBox makeBorder:m_rotationView];
  [m_rotationSlider setValue:[m_pageElement rotation]];
  [self setRotationValue:m_rotationSlider];
  [m_flipButton setState:[m_pageElement isVerticalFlipped] ? CPOnState : CPOffState];
}

- (CPAction)setRotationValue:(id)sender
{
  if ( [sender isKindOfClass:CPTextField] ) {
    [m_rotationSlider setValue:[[sender stringValue] intValue]];
  } else {
    [m_rotationValue setStringValue:(""+[sender intValue])];
  }
  [m_pageElement setRotation:[m_rotationSlider intValue]];

  if ( [m_pageElement respondsToSelector:@selector(redisplay)] ) [m_pageElement redisplay];
}

- (CPAction)setFlipState:(id)sender
{
  [m_pageElement setVerticalFlip:[sender state] == CPOnState ? 1 : 0];
}

@end
