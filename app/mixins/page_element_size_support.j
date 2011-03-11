@implementation PageElementSizeSupport : MixinHelper

- (void)setSize:(CGSize)aSize
{
  width = aSize.width;
  height = aSize.height;
}

- (void)setFrameSize:(CGSize)aSize
{
  [self setSize:aSize];
  // this gets picked up by the document view cell editor view if there is one for this
  // page element. It resizes everything else. If there isn't a document view editor, then
  // the document is not updated by the server will (probably via a 
  // call to sendResizeToServer).
  [[CPNotificationCenter defaultCenter] 
    postNotificationName:PageElementDidResizeNotification
                  object:self];
}

- (CGSize)getSize
{
  return CGSizeMake(width, height);
}

- (PageElement) setLocation:(CGRect)aLocation
{
  x      = aLocation.origin.x;
  y      = aLocation.origin.y;
  width  = aLocation.size.width;
  height = aLocation.size.height;
  return self;
}

- (CGRect) location
{
  return CGRectMake(x, y, width, height);
}

@end
