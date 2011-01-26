@implementation TwitterFeedTE : ToolElement
{
  CPString _forUser;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    _forUser = _json.for_user;
  }
  return self;
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !_forUser ) {
    _forUser = prompt( "Enter the Twitter user name (no leading '@')" );
  }

  if (_mainView) {
    [_mainView removeFromSuperview];
  }
  
  var refView = [[CPTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
  [refView setAutoresizingMask:CPViewNotSizable];
  [refView setFont:[CPFont systemFontOfSize:10.0]];
  [refView setTextColor:[CPColor blueColor]];
  [refView setTextShadowColor:[CPColor whiteColor]];
  [refView setStringValue:[CPString stringWithFormat:"For user %s", _forUser]];

  var imgView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [imgView setAutoresizingMask:CPViewNotSizable];
  [imgView setImageScaling:CPScaleProportionally];
  [imgView setHasShadow:YES];
  [imgView setImage:[[PlaceholderManager sharedInstance] twitterFeed]];

  _mainView = [[CPView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewNotSizable];
  [_mainView addSubview:refView];
  [_mainView addSubview:imgView];

  [refView setFrameOrigin:CGPointMake(20,90)];
  [imgView setFrameOrigin:CGPointMake(0,0)];

  [container addSubview:_mainView];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolTwitter];
}

- (CGSize) initialSize
{
  return CGSizeMake( 150, 275 );
}

@end
