// Similar to the YouTubeTE class, this gets converted to a TweetElement on the
// server side and gets returned as such. But that does not matter since the
// sole purpose of this class is to retrieve tweet data via an URL, one time.
var FindTweetId = new RegExp(/\d+$/);

@implementation TweetTE : Tweet
{
  CPString m_urlString;
  CPView   m_container;
  BOOL     m_send_update_to_server_on_page_element_id;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementInputSupport addToClassOfObject:self];
    m_send_update_to_server_on_page_element_id = NO;
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
      [self initializeFromJson];
      [super generateViewForDocument:m_container];
    } else {
      [self createSpinnerView:m_container];
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
    m_container = container; 
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
  return (typeof(_text) != "undefined");
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

/*
  Return tool element id initially.
*/
- (CPString) id_str
{
  return _json.id;
}

// called once we have an page_element_id for this object. this means we can
// now send an update to the server with the new data that we got from
// twitter.
- (void) havePageElementIdDoAnyUpdate 
{
  if ( m_send_update_to_server_on_page_element_id ) {
    [self updateServer];
    m_send_update_to_server_on_page_element_id = NO;
  }
}

// Called by TweetDataObjectResponse to inform us that the tweet data has arrived.
- (void)tweetDataHasArrived:(Tweet)aTweet
{
  _json = aTweet._json;
  [self initializeFromJson];
  [super generateViewForDocument:m_container];
  if ( page_element_id ) {
    [self updateServer];
  } else {
    m_send_update_to_server_on_page_element_id = YES;
  }
}

@end
