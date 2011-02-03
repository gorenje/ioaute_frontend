@implementation FacebookPhotoCell : BaseImageCell

- (void)setRepresentedObject:(Facebook)anObject
{
  [super setRepresentedObject:anObject];
  [ImageLoaderWorker workerFor:[anObject thumbImageUrl] imageView:m_imageView];
}

@end
