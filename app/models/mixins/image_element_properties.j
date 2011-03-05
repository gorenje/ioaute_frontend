@implementation ImageElementProperties : MixinHelper
{
  CPString m_destUrl @accessors(property=linkUrl,readonly);
  int m_reloadInterval @accessors(property=reloadInterval);
  int m_rotation @accessors(property=rotation);
}

- (void)setImagePropertiesFromJson
{
  m_destUrl        = _json.dest_url;
  m_reloadInterval = ( is_defined(_json.reload_interval) ? 
                       parseInt(_json.reload_interval) : 0 );
  m_rotation = ( is_defined(_json.rotation) ? 
                 parseInt(_json.rotation) : 0 );
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

@end
