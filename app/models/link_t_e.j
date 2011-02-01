@implementation LinkTE : ToolElement
{
  CPString _urlString;
  CPString _linkTitle;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    _urlString = _json.url;
    _linkTitle = _json.title;
  }
  return self;
}

- (void)generateViewForDocument:(CPView)container
{
  // TODO retrieve the page and grab the title value in the header (if it's a html page)
  if ( !_urlString ) {
    _urlString = prompt("Please enter link");
    try {
      var urlObj = [CPURL URLWithString:_urlString];
      if ( urlObj ) {
        _linkTitle = [urlObj lastPathComponent];
        if ( !_linkTitle || _linkTitle == "" ) {
          _linkTitle = _urlString;
        }
      } else {
        _linkTitle = @"Not Available";
      }
    } catch (e){
      _linkTitle = @"Not Available";
    }
  }

  if ( _mainView ) {
    [_mainView removeFromSuperview];
  }

  _mainView = [[CPTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
  [_mainView setAutoresizingMask:CPViewNotSizable];
  [_mainView setFont:[CPFont systemFontOfSize:12.0]];
  [_mainView setTextColor:[CPColor blueColor]];
  [_mainView setTextShadowColor:[CPColor whiteColor]];
  [_mainView setStringValue:[CPString stringWithFormat:"%s", _linkTitle]];

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

//
// Property Handling
//
- (BOOL) hasProperties
{
  return YES;
}

- (void)openProperyWindow
{
  var controller = [PropertyLinkTEController alloc];
  [controller initWithWindowCibName:@"LinkTEProperties" withObject:self];
  [controller showWindow:self];
  [controller setDelegate:self];
}

- (void) setLinkColor:(CPColor)aColor
{
  // TODO send the color to the server. Probably could move the color property to the
  // TextElement base class since everything will have a color.
  [_mainView setTextColor:aColor];
}

- (void) setLinkTitle:(id)aValue
{
  _linkTitle = aValue;
  [_mainView setStringValue:[CPString stringWithFormat:"%s", _linkTitle]];
}
- (void)setLinkDestination:(CPString)urlDestination
{
  _urlString = urlDestination;
}


- (CPString)getDestination
{
  return _urlString;
}

- (CPString)getLinkTitle
{
  return _linkTitle;
}

@end

//
// Property Controller for the LinkTE page element.
//
@implementation PropertyLinkTEController : CPWindowController
{
  @outlet CPColorWell m_colorWell;
  @outlet CPTextField m_linkDestination;
  @outlet CPTextField m_linkTitle;

  id m_link_obj;
}

- (id)initWithWindowCibName:(CPString)cibName withObject:(id)anObject
{
  self = [super initWithWindowCibName:cibName];
  if ( self ) {
    m_link_obj = anObject;
  }
  return self;
}

- (void)awakeFromCib
{
  [m_linkTitle setStringValue:[m_link_obj getLinkTitle]];
  [m_linkDestination setStringValue:[m_link_obj getDestination]];
  
  [[CPNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(windowWillClose:)
                                               name:CPWindowWillCloseNotification
                                             object:_window];
}

- (void) windowWillClose:(CPNotification)aNotification
{
}

- (void) setDelegate:(id)anObject
{
}

- (CPAction)cancel:(id)sender
{
  [_window close];
}

- (CPAction)accept:(id)sender
{
  [m_link_obj setLinkTitle:[m_linkTitle stringValue]];
  [m_link_obj setLinkDestination:[m_linkDestination stringValue]];
  [m_link_obj setLinkColor:[m_colorWell color]];
  [m_link_obj updateServer];
  [_window close];
}

@end
