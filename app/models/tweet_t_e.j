var FindTweetId = new RegExp(/\/\d+$/);

@implementation TweetTE : Tweet
{
  CPString m_urlString;
  CPView m_container;
}

- (void)generateViewForDocument:(CPView)container
{
  CPLogConsole("We're generating the view!");
  if ( !m_urlString ) {
    m_container = container;
    // Ignore the value of the urlString, if it's not an image or something else (i.e. 
    // cancel) then a spinner will be shown. This can then be removed from the document.
    m_urlString = prompt("Enter the URL of the tweet, e.g. " +
                         "http://twitter.com/#!/engineyard/status/37678550509158400");
    var idStr = FindTweetId.exec(m_urlString);
    if ( idStr ) {
      idStr = [idStr[0] substringFromIndex:1];
      CPLogConsole("We have id string: [" + idStr + "]");
      [TweetObjForRequest setObject:self forKey:idStr];
      var tweet_data = [[DragDropManager sharedInstance] 
                         tweetForId:idStr];
      if ( tweet_data ) {
        _json = tweet_data._json;
        [self initializeFromJson];
        [super generateViewForDocument:container];
      } else {
        _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
        [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
        [_mainView setImageScaling:CPScaleToFit];
        [_mainView setHasShadow:NO];
        [_mainView setImage:[[PlaceholderManager sharedInstance] spinner]];
        [container addSubview:_mainView];
      }
    } else {
      CPLogConsole( "!!!! No IDSTR found");
    }
  } else {
    // TODO if ( we_have_tweet_data ) {
    [super generateViewForDocument:container];
    // TODO }
  }
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
}

@end
