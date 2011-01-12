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
  // Default is to pop up a todo alert.
  alertUserWithTodo("This tool is still being built" );
}

- (CPImage)toolBoxImage
{
  // *** This needs to be implemented by the subclass ***
  //
  // Replace this with our tool image. This is image is incorporated into the tool box
  // used to drag tools into the publication.
  return [[PlaceholderManager sharedInstance] toolUnknown];
}

@end
