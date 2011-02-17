// Simple to the YouTubeTE class, this gets converted to a TweetElement on the
// server side and gets returned as such. But that does not matter since the
// sole purpose of this class is to retrieve tweet data via an URL, one time.
var FindTweetId = new RegExp(/\d+$/);

@implementation TweetTE : Tweet
{
  CPString m_urlString;
  CPView m_container;
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !m_urlString ) {
    // Ignore the value of the urlString, if it's not an image or something else (i.e. 
    // cancel) then a spinner will be shown. This can then be removed from the document.
    m_urlString = prompt("Enter the URL of the tweet, e.g. " +
                         "http://twitter.com/#!/engineyard/status/37678550509158400");
    var idStr = FindTweetId.exec(m_urlString);
    if ( idStr ) {
      idStr = idStr[0];
      m_container = container; // only need this if we request the tweet data
      [TweetObjForRequest setObject:self forKey:idStr];
      // the following will trigger a callback to obtain the tweet data,
      // that's why we register a tweet object for the request
      // BTW we can't register the callback after this call since we don't
      // (beforehand) if the tweet exists (and no request is generated) or
      // tweet does not exist and request is generated.
      var tweet_data = [[DragDropManager sharedInstance] tweetForId:idStr];

      if ( tweet_data ) {
        _json = tweet_data._json;
        [self initializeFromJson];
        [super generateViewForDocument:container];
      } else {
        [self createSpinnerView:container];
      }
    } else {
      [self createSpinnerView:container];
    }
  } else {
    if ( [self possibleToShowTweet] ) {
      [super generateViewForDocument:container];
    } else {
      [self createSpinnerView:container];
    }
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

- (CPString) id_str
{
  return _json.id;
}

// Called by TweetDataObjectResponse to inform use of the obvious.
- (void)tweetDataHasArrived:(Tweet)aTweet
{
  _json = aTweet._json;
  [self initializeFromJson];
  [super generateViewForDocument:m_container];
  [self updateServer];
}

@end