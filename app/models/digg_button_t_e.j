@implementation DiggButtonTE : ToolElement
{
}

- (void)generateViewForDocument:(CPView)container
{
  if (_mainView) {
    [_mainView removeFromSuperview];
  }
  
  _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleProportionally];
  [_mainView setHasShadow:YES];

  [container addSubview:_mainView];

  [_mainView setImage:[[PlaceholderManager sharedInstance] diggButton]];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolDigg];
}

- (CGSize) initialSize
{
  return CGSizeMake( 94, 46 );
}

@end

