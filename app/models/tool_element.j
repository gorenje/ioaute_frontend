@import <Foundation/CPObject.j>

@implementation ToolElement : PageElement
{
}

+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  var objAry = [];
  var idx = someJSONObjects.length;

  while ( idx-- ) {
    var klazz = CPClassFromString(someJSONObjects[idx].klazz);
    objAry.push( [[klazz alloc] initWithJSONObject:someJSONObjects[idx]] );
  }

  return objAry;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
  }
  return self;
}

- (CPString) name
{
  return _json.name;
}

- (CPString) id_str
{
  return _json.id;
}

- (void)generateViewForDocument:(CPView)container
{
  // Do nothing since each tool element has it's own representation.
}

@end
