@implementation ImageElementProperties : MixinHelper
{
  CPString m_destUrl;
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

- (void) setDestUrlFromJson:(CPString)alternativeUrl
{
  if ( typeof(_json.dest_url) != "undefined" ) {
    m_destUrl = _json.dest_url;
  } else {
    m_destUrl = alternativeUrl;
  }
}
// The following two need to be implemented by the class that uses this mixin.
// - (void)setImageUrl:(CPString)aString
// {
//   m_urlString = aString;
//   [ImageLoaderWorker workerFor:m_urlString imageView:_mainView];
// }

// - (CPString)getImageUrl
// {
//   return m_urlString;
// }

- (void)setLinkUrl:(CPString)aString
{
  m_destUrl = aString;
}

- (CPString)getLinkUrl
{
  return m_destUrl;
}

- (CGSize)getImageSize
{
  return [[_mainView image] size];
}

@end
