@implementation Page : CPObject
{
  JSObject _json;

  CPString m_name        @accessors(property=name);
  CPString m_pageIdx     @accessors(property=pageIdx);
  int      m_number      @accessors(property=number);
  CPString m_size        @accessors(property=size);
  CPString m_orientation @accessors(property=orientation);
}

+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PageElement generateObjectsFromJson:someJSONObjects forClass:self];
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super init];
  if (self) {
    [PageElementColorSupport addToClass:[self class]];
    _json            = anObject.page;
    m_number         = _json.number;
    m_name           = _json.name;
    m_pageIdx        = _json.id;
    m_size           = _json.size;
    m_orientation    = _json.orientation;
    [self setColorFromJson];
  }
  return self;
}

- (BOOL) isLetter
{
  return (m_size == "letter");
}

- (BOOL) isLandscape
{
  return (m_orientation == "landscape");
}

- (void)updateServer
{
  [[CommunicationManager sharedInstance] updatePage:self];
}

- (CGSize)getFrameSize
{
  var size;
  if ( [self isLetter]  ) {
    size = [[ConfigurationManager sharedInstance] getLetterSize];
  } else {
    size = [[ConfigurationManager sharedInstance] getA4Size];
  }
  if ( [self isLandscape] ) {
    size = CGSizeMake( size.height, size.width );
  }
  return size;
}

- (void)requestCompleted:(CPObject)data
{
  CPLogConsole("[Page] request completed with " + data);

  switch ( data.action ) {
  case "pages_update":
    if ( data.status == "ok" ) {
      CPLogConsole("Page Object was updated");
    }
    break;
  }
}

@end
