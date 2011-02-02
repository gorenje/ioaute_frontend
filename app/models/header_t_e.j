@implementation HeaderTE : TextTE
{
}

- (void)generateViewForDocument:(CPView)container
{
  [super generateViewForDocument:container];
  [_mainView setFont:[CPFont systemFontOfSize:m_fontSize]];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolText];
}

@end

