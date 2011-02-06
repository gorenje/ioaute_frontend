@implementation YouTubePhotoCell : BaseImageCell

- (void)setRepresentedObject:(YouTubeVideo)anObject
{
  [super setRepresentedObject:anObject];
  [ImageLoaderWorker workerFor:[anObject thumbnailImageUrl] imageView:m_imageView];
}

@end
