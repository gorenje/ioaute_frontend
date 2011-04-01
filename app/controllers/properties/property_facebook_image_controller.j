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
@implementation PropertyFacebookImageController : PropertyWindowController

- (void)includeMixins
{
  [PropertyControllerRotationSupport addToClassOfObject:self];
  [PropertyControllerImageSupport addToClassOfObject:self];
  [PropertyControllerImageFlagSupport addToClassOfObject:self];
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [self awakeFromCibSetupImageFields];
  [self awakeFromCibSetupRotationFields:m_pageElement];
  [self setFocusOn:m_widthField];
  [self setupFlagFields:[m_linksView subviews]];
}

- (CPAction)accept:(id)sender
{
  [_window close];
  [m_pageElement setReloadInterval:[m_reloadSlider intValue]];
  [m_pageElement setLinkUrl:[m_linkField stringValue]];
  [m_pageElement setImageUrl:[m_urlField stringValue]];

  [self updateFrameSize];
  [m_pageElement setRotation:[m_rotationSlider intValue]];

  [m_pageElement updateServer];
  [m_pageElement sendResizeToServer];
}

@end
