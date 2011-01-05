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
  [_imgView setImage:anImage];
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !_urlString ) {
    // Ignore the value of the urlString, if it's not an image or something else (i.e. 
    // cancel) then a spinner will be shown. This can then be removed from the document.
    _urlString = prompt("Enter the URL of the image");
  }

  if (!_mainView) {
    CPLogConsole("[ImageTE] Bounds: " + [container bounds]);

    _imgView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
    [_imgView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [_imgView setImageScaling:CPScaleProportionally];
    [_imgView setBackgroundColor:[CPColor blueColor]]; // REMOVE ME
    [_imgView setHasShadow:YES];

    _mainView = [[CPView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
    [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [_mainView addSubview:_imgView];
    
    [self setLocation:[container frame]];
    [self addToServer];
  }

  [container addSubview:_mainView];
  var image = [[CPImage alloc] initWithContentsOfFile:_urlString];
  [image setDelegate:self];

  if ([image loadStatus] != CPImageLoadStatusCompleted) {
    [_imgView setImage:[[PlaceholderManager sharedInstance] spinner]];
  }
}

@end
