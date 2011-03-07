// Send off a request for an image and update the image view when the images arrives.
// In the meantime, set the spinner as image for the image view.
@implementation ImageLoaderWorker : CPObject
{
  CPImage     m_image;
  CPImageView m_imageView;

  // called after the view has the image set.
  id m_delegate;
  SEL m_selector;
}

+ (ImageLoaderWorker)workerFor:(CPString)urlStr 
                     imageView:(CPImageView)aImageView
{
  return [[ImageLoaderWorker alloc] 
           initWithUrl:urlStr 
             imageView:aImageView
             tempImage:[[PlaceholderManager sharedInstance] spinner]
              delegate:nil
              selector:nil];
}

+ (ImageLoaderWorker)workerFor:(CPString)urlStr 
                     imageView:(CPImageView)aImageView 
                     tempImage:(CPImage)aImage
{
  return [[ImageLoaderWorker alloc] 
           initWithUrl:urlStr 
             imageView:aImageView
             tempImage:aImage
              delegate:nil
              selector:nil];
}

+ (ImageLoaderWorker)workerFor:(CPString)urlStr 
                     imageView:(CPImageView)aImageView
                      delegate:(id)aDelegate
                      selector:(SEL)aSelector
{
  return [[ImageLoaderWorker alloc] 
           initWithUrl:urlStr 
             imageView:aImageView
             tempImage:[[PlaceholderManager sharedInstance] spinner]
              delegate:aDelegate
              selector:aSelector];
}

- (id)initWithUrl:(CPString)urlStr 
        imageView:(CPImageView)anImageView 
        tempImage:(CPImage)aImage
         delegate:(id)aDelegate
         selector:(SEL)aSelector
{
  self = [super init];
  if (self) {
    m_imageView = anImageView;
    m_image = [[CPImage alloc] initWithContentsOfFile:urlStr];
    m_delegate = aDelegate;
    m_selector = aSelector;

    [m_image setDelegate:self];
    if ([m_image loadStatus] != CPImageLoadStatusCompleted) {
      [m_imageView setImage:aImage];
    }
  }
  return self;
}

- (void)imageDidLoad:(CPImage)anImage
{
  [m_imageView setImage:anImage];
  if ( m_delegate && m_selector ) {
    [m_delegate performSelector:m_selector withObject:anImage];
  }
}

@end

// Used by the placeholder to manage it's images. This is the same as above except
// it loads from a "local" path and not URL.
@implementation PMGetImageWorker : CPObject
{
  CPImage image @accessors;
  CPString path @accessors;
}

+ (PMGetImageWorker)workerFor:(CPString)pathStr
{
  return [[PMGetImageWorker alloc] initWithPath:pathStr];
}

- (id)initWithPath:(CPString)pathStr
{
  self = [super init];
  if (self) {
    path = pathStr;
    CPLogConsole("[PLM] worker retrieving image @ " + path);
    image = [[CPImage alloc] initWithContentsOfFile:path];
    [image setDelegate:self];
  }
  return self;
}

- (void)imageDidLoad:(CPImage)anImage
{
  CPLogConsole("[PLM] worker loaded image: " + anImage);
  image = anImage;
}

@end
