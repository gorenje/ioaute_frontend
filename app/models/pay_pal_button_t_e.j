@implementation PayPalButtonTE : ToolElement
{
  CPString m_email;
  CPString m_currency;
  CPString m_locale;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    m_email    = _json.email;
    m_currency = ( typeof(_json.currency) == "undefined" ? "USD" : _json.currency );
    m_locale   = ( typeof(_json.locale) == "undefined" ? "en_US" : _json.locale );
  }
  return self;
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !m_email ) {
    m_email = prompt("Enter recipient email, does not need to have an PayPal account:");
  }

  if (_mainView) {
    [_mainView removeFromSuperview];
  }

  _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleProportionally];
  [_mainView setHasShadow:NO];
  [_mainView setImage:[[PlaceholderManager sharedInstance] payPalButton]];
  [container addSubview:_mainView];
}


- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolPayPalButton];
}

- (CGSize) initialSize
{
  return [[[PlaceholderManager sharedInstance] payPalButton] size];
}

@end
