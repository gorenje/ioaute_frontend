var PromptText = ("Enter the Twitter term string. This can be '#term' for a "+
                  "hash-search, '@user' to search for all tweets sent to a " +
                  "specific user or 'user' meaning all tweets from user.");

@implementation TwitterFeedTE : ToolElement
{
  CPView m_refView;
  CPString m_term_string;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementInputSupport addToClass:[self class]];
    m_term_string = _json.term_string;
  }
  return self;
}

- (CPString)refViewText
{
  if ( !m_term_string || [m_term_string isBlank] ) {
    return "NO TERM STRING SUPPLIED";
  }

  switch ( [m_term_string substringWithRange:CPMakeRange(0,1)] ) {
  case '@':
    return [CPString stringWithFormat:"All tweets to %s", m_term_string];
    break;

  case '#':
    return [CPString stringWithFormat:"Searching for %s", m_term_string];
    break;

  default:
    return [CPString stringWithFormat:"All tweets from %s", m_term_string];
  }
}

- (void)promptDataCameAvailable:(CPString)responseValue
{
  if ( !(m_term_string === responseValue) ) {
    m_term_string = responseValue;
    [self updateServer];
    [m_refView setStringValue:[self refViewText]];
  }
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !m_term_string ) {
    m_term_string = [self obtainInput:PromptText defaultValue:"#internet"];
  }

  if (_mainView) {
    [_mainView removeFromSuperview];
  }
  
  m_refView = [[CPTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
  [m_refView setAutoresizingMask:CPViewNotSizable];
  [m_refView setFont:[CPFont systemFontOfSize:10.0]];
  [m_refView setTextColor:[CPColor blueColor]];
  [m_refView setTextShadowColor:[CPColor whiteColor]];
  [m_refView setStringValue:[self refViewText]];

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
  return m_term_string;
}

- (CPString)setForUser:(CPString)aString
{
  m_term_string = aString;
  [m_refView setStringValue:[self refViewText]];
}

@end
