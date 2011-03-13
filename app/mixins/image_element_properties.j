@implementation ImageElementProperties : MixinHelper
{
  CPString m_destUrl @accessors(property=linkUrl,readonly);
  int m_reloadInterval @accessors(property=reloadInterval);
  int m_rotation @accessors(property=rotation,readonly);
}

- (void)setImagePropertiesFromJson
{
  m_destUrl        = _json.dest_url;
  m_reloadInterval = [check_for_undefined(_json.reload_interval,"0") intValue];
  m_rotation       = [check_for_undefined(_json.rotation,"0") intValue];
}

/*!
  Extra functionality for specific classes, e.g. facebook.
*/
- (void) setDestUrlFromJson:(CPString)alternativeUrl
{
  m_destUrl = is_defined(_json.dest_url) ? _json.dest_url : alternativeUrl;
}

- (BOOL) hasProperties 
{ 
  return YES; 
}

- (void)openProperyWindow
{
  [[[PropertyImageTEController alloc] initWithWindowCibName:ImageTEPropertyWindowCIB 
                                                pageElement:self] showWindow:self];
}

// The following two need to be implemented by the class that uses this mixin.
//   - (void)setImageUrl:(CPString)aString { }
//   - (CPString)imageUrl { }
// We don't define these here because this mixin would override the class' 
// implementation of these methods.

- (void)setLinkUrl:(CPString)aString
{
  m_destUrl = aString;
}

- (CGSize)getImageSize
{
  return [[_mainView image] size];
}

- (void)setRotation:(int)aRotValue
{
  m_rotation = aRotValue;
  if ( [_mainView respondsToSelector:@selector(setRotationDegrees:)] ) {
    [_mainView setRotationDegrees:m_rotation];
  }
}

- (void)generateViewForDocument:(CPView)container withUrl:(CPString)url
{
  if (_mainView) {
    [_mainView removeFromSuperview];
  }

  _mainView = [[PMImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleToFit];
  [_mainView setHasShadow:NO];
  [ImageLoaderWorker workerFor:url 
                     imageView:_mainView
                      rotation:[self rotation]];
  [container addSubview:_mainView];
}

@end
