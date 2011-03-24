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
@implementation BaseImageCell : CPView
{
  CPImageView     m_imageView;
  CPView          m_highlightView;
}

- (void)setRepresentedObject:(id)anObject
{
  if (!m_imageView) {
    m_imageView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([self bounds])];
    [m_imageView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [m_imageView setImageScaling:CPScaleProportionally];
    [m_imageView setHasShadow:YES];

    [self addSubview:m_imageView];
  }
}

- (void)setSelected:(BOOL)flag
{
  if (!m_highlightView) [self createHighlightView];

  if (flag) {
    [m_highlightView setFrame:[self bounds]];
    [self addSubview:m_highlightView positioned:CPWindowBelow relativeTo:m_imageView];
  } else {
    [m_highlightView removeFromSuperview];
  }
}

- (void) createHighlightView
{
  m_highlightView = [[CPView alloc] initWithFrame:[self bounds]];
  [m_highlightView setBackgroundColor:[CPColor colorWithCalibratedWhite:0.1 alpha:0.6]];
  [m_highlightView setAutoresizingMask:CPViewWidthSizable|CPViewHeightSizable];
}

@end
