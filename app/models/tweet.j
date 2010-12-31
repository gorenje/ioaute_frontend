@import <LPKit/LPMultiLineTextField.j>

@import <Foundation/CPObject.j>

@implementation Tweet : PageElement
{
  CPImage              _quoteImage;
  CPImageView          _quoteView;
  LPMultiLineTextField _textView;
  CPTextField          _refView;
}

//
// Class method for creating an array of Tweet objects from JSON
//
+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PageElement generateObjectsFromJson:someJSONObjects forClass:self];
}

+ (CPString)searchUrl:(CPString)search_term
{
  return "http://search.twitter.com/search.json?q=" + encodeURIComponent(search_term);
}

// Use this API to get more information on the tweet, i.e. user name and screen name.
// function twitterUrlForTweet(id_str)
// {
//   var api_version = "1"; /* make it obvious where the api version is to be found */
//   return "http://api.twitter.com/" + api_version + "/statuses/show/" + id_str + ".json";
// }

- (CPString) id_str
{
  return _json.id_str;
}

- (CPString) fromUser
{
  return _json.from_user;
}

- (CPString) text
{
  return _json.text;
}

- (void)generateViewForDocument:(CPView)container
{
  if (!_mainView) {

    _quoteView = [[CPImageView alloc] initWithFrame:CGRectMake(0,0,40,40)];
    [_quoteView setHasShadow:YES];
    [_quoteView setImage:[[PlaceholderManager sharedInstance] quotes]];

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
    [_refView setFrameOrigin:CGPointMake(42,10)];
    [_textView setFrameOrigin:CGPointMake(10,40)];

    [self setLocation:[container frame]];
    [self addToServer];
  }

  [container addSubview:_mainView];
  [_textView setStringValue:[self text]];
  [_refView setStringValue:[self fromUser]];
  [_mainView setFrameOrigin:CGPointMake(5,5)];
}

@end
