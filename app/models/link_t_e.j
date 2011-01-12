@implementation LinkTE : ToolElement
{
  CPString _urlString;
  CPString _linkTitle;
}

- (void)cloneFromObj:(PageElement)obj
{
  self._urlString = obj._urlString;
  self._linkTitle = obj._linkTitle;
}

- (void)generateViewForDocument:(CPView)container
{
  // TODO retrieve the page and grab the title value in the header (if it's a html page)
  if ( !_urlString ) {
    _urlString = prompt("Please enter link");
    try {
      var urlObj = [CPURL URLWithString:_urlString];
      if ( urlObj ) {
        _linkTitle = [urlObj lastPathComponent];
        if ( !_linkTitle || _linkTitle == "" ) {
          _linkTitle = _urlString;
        }
      } else {
        _linkTitle = @"Not Available";
      }
    } catch (e){
      _linkTitle = @"Not Available";
    }
  }

  if ( _mainView ) {
    [_mainView removeFromSuperview];
  }

  _mainView = [[CPTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
  [_mainView setAutoresizingMask:CPViewNotSizable];
  [_mainView setFont:[CPFont systemFontOfSize:12.0]];
  [_mainView setTextColor:[CPColor blueColor]];
  [_mainView setTextShadowColor:[CPColor whiteColor]];
  [_mainView setStringValue:[CPString stringWithFormat:"%s", _linkTitle]];

  [container addSubview:_mainView];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolLink];
}

@end
