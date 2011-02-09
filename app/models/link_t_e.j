@implementation LinkTE : ToolElement
{
  CPString m_urlString;
  CPString m_linkTitle;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    CPLogConsole("[Link] mixing in color and font support");
    [PageElementColorSupport addToClass:[self class]];
    [PageElementFontSupport addToClass:[self class]];
    m_urlString = _json.url;
    m_linkTitle = _json.title;
    [self setColorFromJson];
    [self setFontFromJson];
  }
  return self;
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !m_urlString ) {
    m_urlString = prompt("Please enter link");
    try {
      var urlObj = [CPURL URLWithString:m_urlString];
      if ( urlObj ) {
        m_linkTitle = [urlObj lastPathComponent];
        if ( !m_linkTitle || m_linkTitle == "" ) {
          m_linkTitle = m_urlString;
        }
      } else {
        m_linkTitle = @"Not Available";
      }
    } catch (e){
      m_linkTitle = @"Not Available";
    }
  }

  if ( _mainView ) {
    [_mainView removeFromSuperview];
  }

  _mainView = [[CPTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [self _setFont];
  [_mainView setFont:m_fontObj];
  [_mainView setTextColor:m_color];
  [_mainView setStringValue:[CPString stringWithFormat:"%s", m_linkTitle]];

  [container addSubview:_mainView];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolLink];
}

- (CGSize) initialSize
{
  return CGSizeMake( 150, 33.5 );
}

@end

// ---------------------------------------------------------------------------------------
@implementation LinkTE (PropertyHandling)

- (BOOL) hasProperties
{
  return YES;
}

- (void)openProperyWindow
{
  [[[PropertyLinkTEController alloc] initWithWindowCibName:LinkTEPropertyWindowCIB 
                                               pageElement:self] showWindow:self];
}

//
// Setters
//
- (void) setLinkColor:(CPColor)aColor
{
  [self setColor:aColor];
  [_mainView setTextColor:aColor];
}

- (void) setLinkTitle:(id)aValue
{
  m_linkTitle = aValue;
  [_mainView setStringValue:[CPString stringWithFormat:"%s", m_linkTitle]];
}

- (void)setLinkDestination:(CPString)urlDestination
{
  m_urlString = urlDestination;
}

//
// Getters
//
- (CPString)getDestination
{
  return m_urlString;
}

- (CPString)getLinkTitle
{
  return m_linkTitle;
}

@end
