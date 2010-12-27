@import <Foundation/CPObject.j>

/*
 * PM == publish me
 */
@implementation PMDataSource : CPObject
{
  JSObject _json;
  /*
   * Use the _mainView as the view reference. I.e. generateViewForDocument
   * must initialise this instance variable. This then allows for more generalisation.
   */
  CPView   _mainView;
  CPString idStr    @accessors;
  int      page_element_id;

  // We split the location since it's then set over the wire automagically
  float x;
  float y;
  float width;
  float height;
}

/*
 * Used by subclasses to generate a bunch of classes from JSON Data that came
 * back over the wire.
 */
+ (CPArray) generateObjectsFromJson:(CPArray)someJSONObjects forClass:(CPObject)klass
{
  var objects = [[CPArray alloc] init];
  for (var idx = 0; idx < someJSONObjects.length; idx++) {
    [objects addObject:[[klass alloc] initWithJSONObject:someJSONObjects[idx]]] ;
  }
  return objects;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super init];
  if (self) {
    _json = anObject;
    idStr = [self id_str];
  }
  return self;
}

- (CPObject)clone
{
  return [[[self class] alloc] initWithJSONObject:_json];
}

- (int) pageElementId
{
  return page_element_id;
}

- (CPString) id_str
{
  // This needs to be implemented by the subclass and provides a unique id _string_
  // across all objects of the same class. This is normally the id used by the
  // DataSource provider, i.e. Twitter, Flickr, etc.
  return nil;
}

- (void)removeFromSuperview
{
  [[CommunicationManager sharedInstance] deleteElement:self];
  [_mainView removeFromSuperview];
}

- (void)addToServer
{
  [[CommunicationManager sharedInstance] addElement:self];
}

- (void)generateViewForDocument:(CPView)container
{
  // this needs to be implemented by the subclass.
}

- (PMDataSource) setLocation:(CGRect)aLocation
{
  x      = aLocation.origin.x;
  y      = aLocation.origin.y;
  width  = aLocation.size.width;
  height = aLocation.size.height;
  return self;
}

- (void)requestCompleted:(CPObject)data
{
  CPLogConsole("[PM DATA SOURCE] request completed with " + data);

  switch ( data.action ) {
  case "page_element_create":
    if ( data.status == "ok" ) {
      page_element_id = data.page_element_id;
    }
    CPLogConsole([self pageElementId], "create action: " + data.status, "[PM DATA SRC]");
    break;
  case "page_element_resize":
    CPLogConsole(data.status, "resize action", "[PM DATA SRC]");
    break;
  case "page_element_delete":
    CPLogConsole(data.status, "delete action", "[PM DATA SRC]");
    break;
  }
}

@end
