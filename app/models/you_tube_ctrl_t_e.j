@implementation YouTubeCtrlTE : ToolElement
{
}

- (void)generateViewForDocument:(CPView)container
{
  if ( _mainView ) {
    [_mainView removeFromSuperview];
  }

  _mainView = [[CPView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];

  var titleView = [[CPTextField alloc] 
                    initWithFrame:CGRectMake(0,0,170,40)];
  [titleView setFont:[CPFont systemFontOfSize:15.0]];
  [titleView setTextColor:[CPColor blackColor]];
  [titleView setStringValue:"You Tube Video Controls"];

  var playAllView = [[CPTextField alloc] 
                    initWithFrame:CGRectMake(0,20,80,40)];
  [playAllView setFont:[CPFont systemFontOfSize:15.0]];
  [playAllView setTextColor:[CPColor blueColor]];
  [playAllView setStringValue:"[Play All]"];

  var loopNoneView = [[CPTextField alloc] 
                    initWithFrame:CGRectMake(76,20,90,40)];
  [loopNoneView setFont:[CPFont systemFontOfSize:15.0]];
  [loopNoneView setTextColor:[CPColor blueColor]];
  [loopNoneView setStringValue:"[Loop None]"];

  [_mainView addSubview:titleView];
  [_mainView addSubview:playAllView];
  [_mainView addSubview:loopNoneView];
  [container addSubview:_mainView];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolYouTube];
}

- (CGSize)initialSize
{
  return [self initialSizeFromJsonOrDefault:CGSizeMake( 170, 42 )];
}

@end

