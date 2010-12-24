@implementation FlickrPhotoCell : CPView
{
  CPImage         image;
  CPImageView     imageView;
  CPView          highlightView;
}

/*
 * The following are required for loading images when the FlickrCollectionView
 * is filled with images.
 */
- (void)setRepresentedObject:(Flickr)anObject
{
  if(!imageView)
  {
    imageView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([self bounds])];
    [imageView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [imageView setImageScaling:CPScaleProportionally];
    [imageView setHasShadow:YES];

    [self addSubview:imageView];
  }
    
  [image setDelegate:nil];

  image = [[CPImage alloc] initWithContentsOfFile:[anObject flickrThumbUrlForPhoto]];

  [image setDelegate:self];
    
  if([image loadStatus] == CPImageLoadStatusCompleted)
    [imageView setImage:image];
  else
    [imageView setImage:[[PlaceholderManager sharedInstance] spinner]];
}

- (void)imageDidLoad:(CPImage)anImage
{
  [imageView setImage:anImage];
}

- (void)setSelected:(BOOL)flag
{
  if(!highlightView)
  {
    highlightView = [[CPView alloc] initWithFrame:[self bounds]];
    [highlightView setBackgroundColor:[CPColor colorWithCalibratedWhite:0.1 alpha:0.6]];
    [highlightView setAutoresizingMask:CPViewWidthSizable|CPViewHeightSizable];
  }

  if(flag)
  {
    [highlightView setFrame:[self bounds]];
    [self addSubview:highlightView positioned:CPWindowBelow relativeTo:imageView];
  }
  else
    [highlightView removeFromSuperview];
}

@end
