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
    _json   = anObject.page;
    number  = _json.number;
    name    = _json.name;
    pageIdx = _json.id;
  }
  return self;
}

@end
