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
@implementation PageElementRotationSupport : GRClassMixin
{
  int m_rotation      @accessors(property=rotation,readonly);
  int m_vertical_flip @accessors(property=verticalFlip);
}

- (void)setRotationFromJson
{
  m_rotation      = [check_for_undefined(_json.rotation,"0") intValue];
  m_vertical_flip = [check_for_undefined(_json.vflip,"0") intValue];
}

- (void)setVerticalFlip:(int)aFlipValue
{
  if ( m_vertical_flip == aFlipValue ) return;
  m_vertical_flip = aFlipValue;
  [_mainView setVerticalFlip:m_vertical_flip];
  [[CPNotificationCenter defaultCenter] 
    postNotificationName:PageElementDidRotateNotification
                  object:self];
}

- (void)setRotation:(int)aRotValue
{
  if ( m_rotation == aRotValue ) return;
  m_rotation = aRotValue;
  [_mainView setRotationDegrees:m_rotation];
  [[CPNotificationCenter defaultCenter] 
    postNotificationName:PageElementDidRotateNotification
                  object:self];
}

- (float)rotationRadians
{
  return m_rotation * (Math.PI / 180);
}

- (CPArray)rotationSupportStateHandlers
{
  return [@selector(rotation),     @selector(setRotation:),
          @selector(verticalFlip), @selector(setVerticalFlip:)];
}

- (BOOL)isVerticalFlipped
{
  return ( m_vertical_flip > 0 );
}

@end
