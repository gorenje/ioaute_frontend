@implementation GoogleImagesPhotoCell : BaseImageCell

- (void)setRepresentedObject:(GoogleImage)anObject
{
  [super setRepresentedObject:anObject];
  [ImageLoaderWorker workerFor:[anObject thumbnailImageUrl] imageView:m_imageView];
}

@end
