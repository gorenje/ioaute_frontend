@import <Foundation/CPObject.j>

@implementation Page : CPObject
{
  JSObject _json;

  CPString name    @accessors;
  CPString pageIdx @accessors;
  int      number  @accessors;
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
    _json   = anObject.page;
    number  = _json.number;
    name    = _json.name;
    pageIdx = _json.id;
    [self setColorFromJson];
  }
  return self;
}

- (void)updateServer
{
  [[CommunicationManager sharedInstance] updatePage:self];
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
