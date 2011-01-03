@import <Foundation/CPObject.j>

@implementation ToolElement : PageElement
{
}

+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  var objAry = [];
  var idx = someJSONObjects.length;

  while ( idx-- ) {
    switch ( someJSONObjects[idx].type ) {
    case "image":
      objAry.push( [[ImageTE alloc] initWithJSONObject:someJSONObjects[idx]] );
      break;
    case "text":
      objAry.push( [[TextTE alloc] initWithJSONObject:someJSONObjects[idx]] );
      break;
    case "link":
      objAry.push( [[ToolElement alloc] initWithJSONObject:someJSONObjects[idx]] );
      break;
    case "file":
      objAry.push( [[ToolElement alloc] initWithJSONObject:someJSONObjects[idx]] );
      break;
    }
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
  if (!_mainView) {
  }
}

@end
