// store a tweet object here for a tweet id so that we can capture the data 
// and display the tweet. This is used by  TweetDataObjectResponse to pass
// the Tweet to a "handler", usually a TweetTE object that requested the tweet
// initially. BTW i hate global variables but in the case, this seems to be
// the best hack solution i could come up with.
TweetObjForRequest = [[CPDictionary alloc] init];

@implementation Tweet : PageElement
{
  CPImage              _quoteImage;
  CPImageView          _quoteView;
  LPMultiLineTextField _textView;
  CPTextField          _refView;

  CPString _fromUser;
  CPString _text;
  CPString m_profileImageUrl;
}

//
// Class method for creating an array of Tweet objects from JSON
//
+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PageElement generateObjectsFromJson:someJSONObjects forClass:self];
}

+ (CPString)urlForId:(CPString)idStr
{
  return ("http://api.twitter.com/1/statuses/show/" + idStr + ".json");
}

+ (CPString)searchUrl:(CPString)search_term
{
  if ( [search_term hasPrefix:@"@"] ) {
    search_term = @"from:" + [search_term substringFromIndex:1];
  }
  if ( [search_term hasPrefix:@" @"] ) {
    search_term = [search_term substringFromIndex:1];
  }
  return "http://search.twitter.com/search.json?q=" + encodeURIComponent(search_term);
}

+ (CPString)nextPageUrl:(CPString)next_page_from_twitter
{
  return (next_page_from_twitter ? ("http://search.twitter.com/search.json" + 
                                    next_page_from_twitter) : nil );
}

+ (void)retrieveTweetAndUpdateDragAndDrop:(CPString)id_string
{
  var respObj = [[TweetDataObjectResponse alloc] init];
  [PMCMWjsonpWorker workerWithUrl:[Tweet urlForId:id_string]
                         delegate:respObj 
                         selector:@selector(responseReturnedData:)];
}

//
// Instance Methods
//
- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) [self initializeFromJson];
  return self;
}

- (void) initializeFromJson
{
  _fromUser         = _json.from_user;
  _text             = _json.text;
  m_profileImageUrl = _json.profile_image_url;
}

- (CPString) id_str
{
  return _json.id_str;
}

- (CPString) fromUser
{
  return _fromUser;
}

- (CPString) text
{
  return _text;
}

- (void)generateViewForDocument:(CPView)container
{
  if (_mainView) {
    [_mainView removeFromSuperview];
  }

  _quoteView = [[CPImageView alloc] initWithFrame:CGRectMake(0,0,48,48)];
  [_quoteView setHasShadow:NO];
  if ( m_profileImageUrl && m_profileImageUrl != "undefined" ) {
    [ImageLoaderWorker workerFor:m_profileImageUrl 
                       imageView:_quoteView
                       tempImage:[[PlaceholderManager sharedInstance] quotes]];
  }

  _textView = [[LPMultiLineTextField alloc] 
                initWithFrame:CGRectInset([container bounds], 4, 4)];
  [_textView setFont:[CPFont systemFontOfSize:12.0]];
  [_textView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_textView setTextShadowColor:[CPColor whiteColor]];
  [_textView setScrollable:YES];
  [_textView setSelectable:YES];

  _refView = [[CPTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
  [_refView setFont:[CPFont systemFontOfSize:10.0]];
  [_refView setTextColor:[CPColor blueColor]];
  [_refView setTextShadowColor:[CPColor whiteColor]];
    
  _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView addSubview:_quoteView];
  [_mainView addSubview:_textView];
  [_mainView addSubview:_refView];
  [_quoteView setFrameOrigin:CGPointMake(0,0)];
  [_refView setFrameOrigin:CGPointMake(50,0)];
  [_textView setFrameOrigin:CGPointMake(0,48)];

  [container addSubview:_mainView];
  [_textView setStringValue:[self text]];
  [_refView setStringValue:[self fromUser]];
  [_mainView setFrameOrigin:CGPointMake(5,5)];
}

@end

//
// Helper object that is used to store the data for a new tweet, i.e. for a drag 
// event that can't find a particular tweet. This is then used to retrieve that tweet.
//
@implementation TweetDataObjectResponse : CPObject
{
}

- (void)responseReturnedData:(JSObject)data
{
  CPLogConsole("[TWEET] Got new tweet, storing to the D&D Mgr: " + data.id);
  // Gotcha: the contents, in this case, are more detailed because we retrieved 
  // one specific tweet. What we need to do is "convert" this object to one 
  // that more terse. Specifically, the initWithJSONObject expects the field 
  // from_user to be set with the screen name of the user.
  data.from_user = data.user.screen_name;
  data.profile_image_url = data.user.profile_image_url;
  var tweet = [[Tweet alloc] initWithJSONObject:data];
  [[DragDropManager sharedInstance] moreTweets:[tweet]];

  // retrieve any handler and pass them the tweet
  var handler = [TweetObjForRequest objectForKey:[tweet id_str]];
  if ( handler ) {
    [TweetObjForRequest removeObjectForKey:[tweet id_str]];
    [handler tweetDataHasArrived:tweet];
  }
}

@end
