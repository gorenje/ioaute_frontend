@implementation FacebookCategoryCell : CPView
{
  CPImageView m_imageView;
  CPView      m_highlightView;
}

// Two kinds of objects are supported, one representing an album of this user
// and second a friend. The intention is to obtain all the photos of the friend
// once clicked on.
- (void)setRepresentedObject:(JSObject)anObject
{
  if ( !m_imageView ) {
    m_imageView = [[CPImageView alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
    [m_imageView setAutoresizingMask:CPViewNotSizable];
    [m_imageView setImageScaling:CPScaleToFit];
    [self addSubview:m_imageView];
  }

  if ( anObject.from ) {
    [self handleAnAlbum:anObject];
  } else { 
    [self handleAFriend:anObject];
  }
}

- (void)handleAnAlbum:(JSObject)anObject
{
  [m_imageView setImage:[[PlaceholderManager sharedInstance] photoAlbum]];
}

- (void)handleAFriend:(JSObject)anObject
{
  var urlString = [CPString stringWithFormat:"https://graph.facebook.com/%s/picture", 
                            anObject.id];
  var image = [[CPImage alloc] initWithContentsOfFile:urlString];
  [image setDelegate:self];

  if ([image loadStatus] != CPImageLoadStatusCompleted) {
    [m_imageView setImage:[[PlaceholderManager sharedInstance] spinner]];
  }
}

- (void)imageDidLoad:(CPImage)anImage
{
  [m_imageView setImage:anImage];
}

- (void)setSelected:(BOOL)flag
{
  if (!m_highlightView) {
    m_highlightView = [[CPView alloc] initWithFrame:[self bounds]];
    [m_highlightView setBackgroundColor:[CPColor colorWithHexString:@"c2ecc5"]];
    [m_highlightView setAutoresizingMask:CPViewWidthSizable|CPViewHeightSizable];
  }

  if (flag) {
    [m_highlightView setFrame:[self bounds]];
    [self addSubview:m_highlightView positioned:CPWindowBelow relativeTo:m_imageView];
  }
  else {
    [m_highlightView removeFromSuperview];
  }
}

@end
