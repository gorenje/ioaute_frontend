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
@implementation YouTubePhotoCell : BaseImageCell
{
  YouTubeVideo m_video_obj;
}

- (void)setRepresentedObject:(YouTubeVideo)anObject
{
  m_video_obj = anObject;
  [super setRepresentedObject:anObject];
  [ImageLoaderWorker workerFor:[anObject thumbnailImageUrl] imageView:m_imageView];
}

- (void)setSelected:(BOOL)flag
{
  [self createHighlightView];

  if (flag) {
    [m_highlightView setFrame:[self bounds]];
    [self addSubview:m_highlightView positioned:CPWindowBelow relativeTo:m_imageView];
  } else {
    [m_highlightView removeFromSuperview];
  }
}

- (void) createHighlightView
{
  if ( m_highlightView ) [m_highlightView removeFromSuperview];
  m_highlightView = nil;
  [super createHighlightView];

  var ownerView = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
  [ownerView setFont:[CPFont systemFontOfSize:10.0]];
  [ownerView setTextColor:[CPColor whiteColor]];
  [ownerView setTextShadowColor:[CPColor blackColor]];
  [ownerView setStringValue:[m_video_obj videoOwner]];
  
  [m_highlightView addSubview:ownerView];
  [ownerView setFrameOrigin:CGPointMake(11,5)];

  var titleView = [[LPMultiLineTextField alloc] 
                    initWithFrame:CGRectInset([self bounds], 4, 4)];
  [titleView setFont:[CPFont systemFontOfSize:10.0]];
  [titleView setTextColor:[CPColor whiteColor]];
  [titleView setTextShadowColor:[CPColor blackColor]];
  [titleView setStringValue:[m_video_obj videoTitle]];
  [m_highlightView addSubview:titleView];
  [titleView setFrameOrigin:CGPointMake(11,120)];
}

@end
