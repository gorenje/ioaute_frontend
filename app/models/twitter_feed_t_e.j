@implementation TwitterFeedTE : ToolElement
{
  CPView m_refView;
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
  
  m_refView = [[CPTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
  [m_refView setAutoresizingMask:CPViewNotSizable];
  [m_refView setFont:[CPFont systemFontOfSize:10.0]];
  [m_refView setTextColor:[CPColor blueColor]];
  [m_refView setTextShadowColor:[CPColor whiteColor]];
  [m_refView setStringValue:[CPString stringWithFormat:"For user %s", _forUser]];

  var imgView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [imgView setAutoresizingMask:CPViewNotSizable];
  [imgView setImageScaling:CPScaleProportionally];
  [imgView setHasShadow:YES];
  [imgView setImage:[[PlaceholderManager sharedInstance] twitterFeed]];

  _mainView = [[CPView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewNotSizable];
  [_mainView addSubview:m_refView];
  [_mainView addSubview:imgView];

  [m_refView setFrameOrigin:CGPointMake(20,90)];
  [imgView setFrameOrigin:CGPointMake(0,0)];

  [container addSubview:_mainView];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolTwitter];
}

- (CGSize) initialSize
{
  return [self initialSizeFromJsonOrDefault:CGSizeMake( 150, 275 )];
}

@end

// ------------------------------------------------------------------------------------------
@implementation TwitterFeedTE (PropertyHandling)

- (BOOL) hasProperties
{ 
  return YES; 
}

- (void)openProperyWindow
{
  [[[PropertyTwitterFeedTEController alloc] initWithWindowCibName:TwitterFeedTEPropertyWindowCIB 
                                                      pageElement:self] showWindow:self];
}

- (CPString)getForUser
{
  return _forUser;
}

- (CPString)setForUser:(CPString)aString
{
  _forUser = aString;
  [m_refView setStringValue:[CPString stringWithFormat:"For user %s", _forUser]];
}

@end
