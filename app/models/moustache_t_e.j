var MoustacheUrl = @"http://assets.2monki.es/images/moustache.png";

@implementation MoustacheTE : ToolElement
{
}

- (void)generateViewForDocument:(CPView)container
{
  if (_mainView) {
    [_mainView removeFromSuperview];
  }
  
  _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleToFit];
  [_mainView setHasShadow:NO];

  [container addSubview:_mainView];

  var image = [[CPImage alloc] initWithContentsOfFile:MoustacheUrl];
  [image setDelegate:self];

  if ([image loadStatus] != CPImageLoadStatusCompleted) {
    [_mainView setImage:[[PlaceholderManager sharedInstance] spinner]];
  }
}

- (void)imageDidLoad:(CPImage)anImage
{
  [_mainView setImage:anImage];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolMoustache];
}

@end
