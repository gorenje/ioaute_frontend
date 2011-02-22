@implementation LinkTE : ToolElement
{
  CPString m_urlString;
  CPString m_linkTitle;
  CPView m_myContainer;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementColorSupport addToClass:[self class]];
    [PageElementFontSupport addToClass:[self class]];
    m_urlString = _json.url;
    m_linkTitle = _json.title;
    [self setColorFromJson];
    [self setFontFromJson];
  }
  return self;
}

- (void) controlTextDidEndEditing:(id)sender
{
  m_linkTitle = [[sender object] stringValue];
  [self updateServer]; // this sends _textTyped to the server, hence we set it first.
}

- (void) controlTextDidFocus:(id)sender
{
  [m_myContainer setSelected:YES];
}

- (void)generateViewForDocument:(CPView)container
{
  m_myContainer = container;
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


  [self _setFont];
  _mainView = [[LPMultiLineTextField alloc] 
                initWithFrame:CGRectInset([container bounds], 4, 4)];
  [_mainView setFont:m_fontObj];
  [_mainView setTextColor:m_color];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setDelegate:self];
  [_mainView setScrollable:YES];
  [_mainView setEditable:YES];
  [_mainView setSelectable:YES];

  [_mainView setStringValue:m_linkTitle];
  [container addSubview:_mainView];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolLink];
}

- (CGSize) initialSize
{
  return [self initialSizeFromJsonOrDefault:CGSizeMake( 150, 33.5 )];
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
