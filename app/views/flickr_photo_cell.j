@implementation FlickrPhotoCell : BaseImageCell

- (void)setRepresentedObject:(Flickr)anObject
{
  [super setRepresentedObject:anObject];
  [ImageLoaderWorker workerFor:[anObject flickrThumbUrlForPhoto] imageView:m_imageView];
}

@end
