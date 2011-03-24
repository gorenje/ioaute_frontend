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
// Similar to the YouTubeTE class, this gets converted to a TweetElement on the
// server side and gets returned as such. But that does not matter since the
// sole purpose of this class is to retrieve tweet data via an URL, one time.
var FindTweetId = new RegExp(/\d+$/);

@implementation TweetTE : Tweet
{
  CPString m_urlString;
  BOOL     mtmp_send_update_to_server_on_page_element_id;
  CPView   mtmp_container;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementInputSupport addToClassOfObject:self];
    mtmp_send_update_to_server_on_page_element_id = NO;
  }
  return self;
}

- (void)promptDataCameAvailable:(CPString)responseValue
{
  m_urlString = responseValue;
  var idStrAry = FindTweetId.exec(m_urlString);
  if ( idStrAry ) {
    [_mainView removeFromSuperview];
    // override the tool element id of this element and set it to the tweet
    // id. this then gets sent to the server and it updates the id of this 
    // element on the server side.
    idStr = idStrAry[0];

    // the following request from the D&D mgr will trigger a callback to obtain 
    // the tweet data, that's why we register a tweet object for the request
    [TweetObjForRequest setObject:self forKey:idStr];

    // BTW we can't register the callback after this call since we don't
    // (beforehand) if the tweet exists (and no request is generated) or
    // tweet does not exist and request is generated.
    var tweet_data = [[DragDropManager sharedInstance] tweetForId:idStr];

    if ( tweet_data ) {
      _json = tweet_data._json;
      idStr = _json.id_str;
      [self initializeFromJson];
      [super generateViewForDocument:mtmp_container];
    } else {
      [self createSpinnerView:mtmp_container];
    }
  }
}

- (void)generateViewForDocument:(CPView)container
{
  if ( m_urlString ) {
    if ( [self possibleToShowTweet] ) {
      [super generateViewForDocument:container];
    } else {
      [self createSpinnerView:container];
    }
  } else {
    mtmp_container = container; 
    [self obtainInput:("Enter the URL of the tweet, e.g. " +
                       "http://twitter.com/#!/engineyard/"+
                       "status/37678550509158400")
         defaultValue:("http://twitter.com/#!/engineyard/"+
                       "status/37678550509158400")];
    [self createSpinnerView:container];
  }
}

- (BOOL)possibleToShowTweet
{
  return is_defined(_text);
}

- (void) createSpinnerView:(CPView)container
{
  _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleToFit];
  [_mainView setHasShadow:NO];
  [_mainView setImage:[[PlaceholderManager sharedInstance] spinner]];
  [container addSubview:_mainView];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolTwitter];
}

- (CPString) name
{
  return _json.name;
}

- (CPString) id_str
{
  return _json.id;
}

- (CPString) toolTip
{
  return _json.tool_tip;
}

// called once we have an page_element_id for this object. this means we can
// now send an update to the server with the new data that we got from
// twitter.
- (void) havePageElementIdDoAnyUpdate 
{
  if ( mtmp_send_update_to_server_on_page_element_id ) {
    [self updateServer];
    mtmp_send_update_to_server_on_page_element_id = NO;
  }
}

// Called by TweetDataObjectResponse to inform us that the tweet data has arrived.
- (void)tweetDataHasArrived:(Tweet)aTweet
{
  _json = aTweet._json;
  [self initializeFromJson];
  idStr = _json.id_str;
  [super generateViewForDocument:mtmp_container];

  if ( page_element_id ) {
    [self updateServer];
  } else {
    mtmp_send_update_to_server_on_page_element_id = YES;
  }
}

@end
