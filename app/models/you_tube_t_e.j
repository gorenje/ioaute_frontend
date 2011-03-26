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
 * Beware that this tool element gets converted to a YouTubeVideo Element on the server
 * side and is returned as such. That means reloading the editor will remove this
 * from the document and replace it with a YouTubeVideo element.
 */
@implementation YouTubeTE : ToolElement
{
  CPString m_origUrl;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [YouTubeVideoProperties addToClassOfObject:self];
    [YouTubePageElement addToClassOfObject:self];
    [PageElementInputSupport addToClassOfObject:self];
    [PageElementRotationSupport addToClassOfObject:self];

    m_origUrl = _json.original_url;
    [self updateFromJson];
    [self setRotationFromJson];
  }
  return self;
}

- (void)promptDataCameAvailable:(CPString)responseValue
{
  m_origUrl = responseValue;
  var urlString = [YouTubeVideo queryUrlForVideo:m_origUrl];
  if ( urlString ) {
    [PMCMWjsonpWorker workerWithUrl:urlString
                           delegate:self
                           selector:@selector(storeDetails:)
                           callback:"callback"];
  }
}

- (void)generateViewForDocument:(CPView)container
{
  if ( _mainView ) {
    [_mainView removeFromSuperview];
  }

  _mainView = [[PMImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleToFit];
  [_mainView setHasShadow:NO];
  [container addSubview:_mainView];

  if ( m_thumbnailUrl ) {
    [ImageLoaderWorker workerFor:m_thumbnailUrl 
                       imageView:_mainView
                        rotation:[self rotation]];
  } else {
    [_mainView setImage:[[PlaceholderManager sharedInstance] spinner]];
  }

  if ( !m_origUrl ) {
    [self obtainInput:("Please YouTube video link, e.g. "+
                       "http://www.youtube.com/watch?v="+
                       "WgYbs-DPe5Y&feature=related")
         defaultValue:"http://www.youtube.com/watch?v=Srmdij0CU1U"];

  }
}

- (void)havePageElementIdDoAnyUpdate
{
  [self updateServer];
}

- (void) storeDetails:(JSObject)data
{
  _json = data.data;
  [self updateFromJson];
  if ( page_element_id ) [self updateServer];
  [ImageLoaderWorker workerFor:m_thumbnailUrl 
                     imageView:_mainView
                      rotation:[self rotation]];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolYouTube];
}

@end

