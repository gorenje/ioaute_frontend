@import <Foundation/CPObject.j>

@implementation Page : CPObject
{
  JSObject _json;

  CPString name   @accessors;
  int      number @accessors;
}

+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PageElement generateObjectsFromJson:someJSONObjects forClass:self];
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super init];
  if (self) {
    _json = anObject.page;
    number = _json.number;
    name = _json.name;
  }
  return self;
}

- (void)requestCompleted:(CPObject)data
{
  CPLogConsole("[PAGE MODEL] request completed with " + data);

  switch ( data.action ) {
  case "pages_destroy":
    // TODO get the page to post a notificatoin that can be caught by the pageViewController
    // TODO to reload the page view.
    CPLogConsole(data.status, "destroy action", "[PAGE]");
    break;
  }
}

@end
