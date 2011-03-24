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
@implementation FacebookCategoryCell : CPView
{
  CPImageView m_imageView;
  CPView      m_highlightView;
}

// Two kinds of objects are supported, one representing an album of this user
// and second a friend. The intention is to obtain all the photos of the friend
// once clicked on.
- (void)setRepresentedObject:(JSObject)anObject
{
  if ( !m_imageView ) {
    m_imageView = [[CPImageView alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
    [m_imageView setAutoresizingMask:CPViewNotSizable];
    [m_imageView setImageScaling:CPScaleToFit];
    [self addSubview:m_imageView];
  }

  if ( anObject.from ) {
    [self handleAnAlbum:anObject];
  } else { 
    [self handleAFriend:anObject];
  }
}

- (void)handleAnAlbum:(JSObject)anObject
{
  [m_imageView setImage:[[PlaceholderManager sharedInstance] photoAlbum]];
}

- (void)handleAFriend:(JSObject)anObject
{
  var urlString = [CPString stringWithFormat:"https://graph.facebook.com/%s/picture", 
                            anObject.id];

  [ImageLoaderWorker workerFor:urlString imageView:m_imageView];
}

- (void)setSelected:(BOOL)flag
{
  if (!m_highlightView) {
    m_highlightView = [[CPView alloc] initWithFrame:[self bounds]];
    [m_highlightView setBackgroundColor:[CPColor colorWithHexString:@"c2ecc5"]];
    [m_highlightView setAutoresizingMask:CPViewWidthSizable|CPViewHeightSizable];
  }

  if (flag) {
    [m_highlightView setFrame:[self bounds]];
    [self addSubview:m_highlightView positioned:CPWindowBelow relativeTo:m_imageView];
  }
  else {
    [m_highlightView removeFromSuperview];
  }
}

@end
