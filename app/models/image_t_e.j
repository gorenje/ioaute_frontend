@implementation ImageTE : ToolElement
{
  CPImageView _imgView;

  CPString _urlString;
}

- (void)cloneFromObj:(PageElement)obj
{
  self._urlString = obj._urlString;
}

- (void)imageDidLoad:(CPImage)anImage
{
  [_mainView setImage:anImage];
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !_urlString ) {
    // Ignore the value of the urlString, if it's not an image or something else (i.e. 
    // cancel) then a spinner will be shown. This can then be removed from the document.
    _urlString = prompt("Enter the URL of the image");
  }

  if (_mainView) {
    [_mainView removeFromSuperview];
  }
  
  CPLogConsole("[ImageTE] Bounds: " + [container bounds]);

  _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleProportionally];
  [_mainView setHasShadow:YES];

  [container addSubview:_mainView];

  var image = [[CPImage alloc] initWithContentsOfFile:_urlString];
  [image setDelegate:self];

  CPLogConsole("Image status: " + [image loadStatus]);
  if ([image loadStatus] != CPImageLoadStatusCompleted) {
    [_mainView setImage:[[PlaceholderManager sharedInstance] spinner]];
  }
}

@end
