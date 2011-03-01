@implementation ImageElementProperties : MixinHelper
{
  CPString m_destUrl;
  int m_reloadInterval @accessors(property=reloadInterval);
}

- (void)setImagePropertiesFromJson
{
  m_destUrl        = _json.dest_url;
  m_reloadInterval = ( is_defined(_json.reload_interval) ? 
                       parseInt(_json.reload_interval) : 0 );
}

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
// - (void)setImageUrl:(CPString)aString { }
// - (CPString)getImageUrl { }

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
