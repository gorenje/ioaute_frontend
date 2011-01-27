@implementation FacebookPhotoCell : CPView
{
  CPImageView     m_imageView;
  CPView          m_highlightView;
}

- (void)setRepresentedObject:(Facebook)anObject
{
  if(!m_imageView)
  {
    m_imageView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([self bounds])];
    [m_imageView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [m_imageView setImageScaling:CPScaleProportionally];
    [m_imageView setHasShadow:YES];

    [self addSubview:m_imageView];
  }

  [ImageLoaderWorker workerFor:[anObject thumbImageUrl] imageView:m_imageView];
}

- (void)setSelected:(BOOL)flag
{
  if (!m_highlightView) {
    m_highlightView = [[CPView alloc] initWithFrame:[self bounds]];
    [m_highlightView setBackgroundColor:[CPColor colorWithCalibratedWhite:0.1 alpha:0.6]];
    [m_highlightView setAutoresizingMask:CPViewWidthSizable|CPViewHeightSizable];
  }

  if (flag) {
    [m_highlightView setFrame:[self bounds]];
    [self addSubview:m_highlightView positioned:CPWindowBelow relativeTo:m_imageView];
  } else {
    [m_highlightView removeFromSuperview];
  }
}

@end
