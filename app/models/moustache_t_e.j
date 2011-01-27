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

  [ImageLoaderWorker workerFor:[PlaceholderManager moustacheImageUrl] imageView:_mainView];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolMoustache];
}

- (CGSize) initialSize
{
  return CGSizeMake( 150, 50 );
}

@end
