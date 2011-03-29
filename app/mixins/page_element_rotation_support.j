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
  int m_rotation @accessors(property=rotation,readonly);
}

- (void)setRotationFromJson
{
  m_rotation = [check_for_undefined(_json.rotation,"0") intValue];
}

- (void)setRotation:(int)aRotValue
{
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
  return [@selector(rotation), @selector(setRotation:)];
}

@end
