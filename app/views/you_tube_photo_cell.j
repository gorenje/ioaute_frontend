@implementation YouTubePhotoCell : BaseImageCell
{
  YouTubeVideo m_video_obj;
}

- (void)setRepresentedObject:(YouTubeVideo)anObject
{
  m_video_obj = anObject;
  [super setRepresentedObject:anObject];
  [ImageLoaderWorker workerFor:[anObject thumbnailImageUrl] imageView:m_imageView];
}

- (void) createHighlightView
{
  [m_highlightView removeFromSuperview];
  m_highlightView = nil;
  [super createHighlightView];

  var ownerView = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
  [ownerView setFont:[CPFont systemFontOfSize:10.0]];
  [ownerView setTextColor:[CPColor whiteColor]];
  [ownerView setTextShadowColor:[CPColor blackColor]];
  [ownerView setStringValue:[m_video_obj videoOwner]];
  
  [m_highlightView addSubview:ownerView];
  [ownerView setFrameOrigin:CGPointMake(11,5)];

  var titleView = [[LPMultiLineTextField alloc] 
                    initWithFrame:CGRectInset([self bounds], 4, 4)];
  [titleView setFont:[CPFont systemFontOfSize:10.0]];
  [titleView setTextColor:[CPColor whiteColor]];
  [titleView setTextShadowColor:[CPColor blackColor]];
  [titleView setStringValue:[m_video_obj videoTitle]];
  [m_highlightView addSubview:titleView];
  [titleView setFrameOrigin:CGPointMake(11,120)];
}

@end
