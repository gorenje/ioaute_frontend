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
@implementation YouTubeCtrlTE : ToolElement

- (void)generateViewForDocument:(CPView)container
{
  if ( _mainView ) {
    [_mainView removeFromSuperview];
  }

  _mainView = [[CPView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  var titleView = [[CPTextField alloc] 
                    initWithFrame:CGRectMake(0,0,170,40)];
  [titleView setFont:[CPFont systemFontOfSize:15.0]];
  [titleView setTextColor:[CPColor blackColor]];
  [titleView setStringValue:"You Tube Video Controls"];

  var playAllView = [[CPTextField alloc] 
                    initWithFrame:CGRectMake(0,20,80,40)];
  [playAllView setFont:[CPFont systemFontOfSize:15.0]];
  [playAllView setTextColor:[CPColor blueColor]];
  [playAllView setStringValue:"[Play All]"];

  var loopNoneView = [[CPTextField alloc] 
                    initWithFrame:CGRectMake(76,20,90,40)];
  [loopNoneView setFont:[CPFont systemFontOfSize:15.0]];
  [loopNoneView setTextColor:[CPColor blueColor]];
  [loopNoneView setStringValue:"[Loop None]"];

  [_mainView addSubview:titleView];
  [_mainView addSubview:playAllView];
  [_mainView addSubview:loopNoneView];
  [container addSubview:_mainView];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolYouTube];
}

- (CGSize)initialSize
{
  return [self initialSizeFromJsonOrDefault:CGSizeMake( 170, 42 )];
}

@end

