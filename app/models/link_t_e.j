@implementation LinkTE : ToolElement
{
  CPString m_urlString;
  CPString m_linkTitle;

  int m_red;
  int m_blue;
  int m_green;
  float m_alpha;
  CPColor m_color;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    m_urlString = _json.url;
    m_linkTitle = _json.title;
    [self setColorFromJson];
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
  [_mainView setAutoresizingMask:CPViewNotSizable];
  [_mainView setFont:[CPFont systemFontOfSize:12.0]];
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
  [super setColor:aColor];
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
