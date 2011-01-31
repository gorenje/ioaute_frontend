@import <LPKit/LPMultiLineTextField.j>

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
  if (self) {
    _fromUser         = _json.from_user;
    _text             = _json.text;
    m_profileImageUrl = _json.profile_image_url;
  }
  return self;
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
  [ImageLoaderWorker workerFor:m_profileImageUrl 
                     imageView:_quoteView
                     tempImage:[[PlaceholderManager sharedInstance] quotes]];

  _textView = [[LPMultiLineTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
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
  CPLogConsole("[TWEET] Got new tweet, storing to the D&D Mgr");
  // Gotcha: the contents, in this case, are more detailed because we retrieved one specific
  // tweet. What we need to do is "convert" this object to one that more terse. Specifically,
  // the initWithJSONObject expects the field from_user to be set with the screen name of
  // of the user.
  data.from_user = data.user.screen_name;
  var tweet = [[Tweet alloc] initWithJSONObject:data];
  var ary = [CPArray arrayWithObjects:tweet];
  [[DragDropManager sharedInstance] moreTweets:ary];
}

@end
