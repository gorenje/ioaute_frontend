@implementation LinkTE : ToolElement
{
  CPString m_urlString;
  CPString m_linkTitle @accessors(property=textTyped);
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementColorSupport addToClassOfObject:self];
    [PageElementFontSupport addToClassOfObject:self];
    [PageElementInputSupport addToClassOfObject:self];
    [PageElementTextInputSupport addToClassOfObject:self];

    m_urlString = _json.url;
    m_linkTitle = _json.title;
    [self setColorFromJson];
    [self setFontFromJson];
  }
  return self;
}

- (void)promptDataCameAvailable:(CPString)responseValue
{
  if ( !(m_urlString === responseValue) ) {
    m_urlString = responseValue;
    m_linkTitle = responseValue;
    [self updateServer];
    [_mainView setStringValue:m_linkTitle];
  }
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !m_urlString ) {
    m_urlString = [self obtainInput:"Please enter link:" defaultValue:"http://bit.ly"];
    m_linkTitle = m_urlString;
  }
  
  if ( _mainView ) {
    [_mainView removeFromSuperview];
  }

  [self _setFont];
  [self setupMainViewAddTo:container];
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
