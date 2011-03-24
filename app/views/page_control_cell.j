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
@implementation PageControlCell : CPView
{
  CPTextField m_label;
  CPButton m_button;
}

- (void)setRepresentedObject:(JSObject)anObject
{
  if ( !m_label && anObject.type == "label")
  {
    m_label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
        
    [m_label setFont:[CPFont systemFontOfSize:12.0]];
    [m_label setVerticalAlignment:CPCenterVerticalTextAlignment];
    [m_label setAlignment:CPLeftTextAlignment];
  }

  switch ( anObject.type ) {

  case "button":
    if ( m_button ) {
      [m_button removeFromSuperview];
    }
    m_button = [[CPButton alloc] initWithFrame:CGRectInset([self bounds], -16, -12)];
    [m_button setImage:[PlaceholderManager imageFor:anObject.image]];
    [m_button setAlternateImage:[PlaceholderManager imageFor:anObject.image]];
    [m_button setImagePosition:CPImageAbove];
    [m_button setImageScaling:CPScaleToFit];

    [m_button setTarget:[PageViewController sharedInstance]];
    [m_button setAction:anObject.selector];
    [m_button setFrameOrigin:CGPointMake(10,CGRectGetHeight([m_button bounds]) / 8)];
    if ( is_defined(anObject.tooltip) ) [m_button setToolTip:anObject.tooltip];

    if ( m_label ) {
      [m_label removeFromSuperview];
    }
    [self addSubview:m_button];
    break;

  case "label":
    [m_label setStringValue:[CPString stringWithFormat:"%s", anObject.name]];
    [m_label sizeToFit];
    [m_label setFrameOrigin:CGPointMake(0,CGRectGetHeight([m_label bounds]) / 2.5)];
    [self addSubview:m_label];
    if ( m_button ) {
      [m_button removeFromSuperview];
    }
    break;
  }
}

@end
