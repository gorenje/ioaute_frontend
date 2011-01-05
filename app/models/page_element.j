@import <Foundation/CPObject.j>

@implementation PageElement : CPObject
{
  /*
   * Private instance variables. All instance variables are automagically sent over
   * the wire to the server. Those without leading '_' are used by the server.
   */

  /*
   * Use the _mainView as the view reference. I.e. generateViewForDocument
   * must initialise this instance variable. This then allows for more generalisation.
   */
  CPView   _mainView;
  int      page_element_id; // no '_' because it's read by the rails server.
  JSObject _json;

  // We split the location up since it's then set over the wire automagically
  float x;
  float y;
  float width;
  float height;

  /*
   * Public instance variables
   */
  CPString idStr @accessors;
}

/*
 * Used by subclasses to generate a bunch of classes from JSON Data that came
 * back over the wire.
 */
+ (CPArray) generateObjectsFromJson:(CPArray)someJSONObjects forClass:(CPObject)klass
{
  var objects = [[CPArray alloc] init],
    idx = someJSONObjects.length;
  while ( idx-- ) {
    [objects addObject:[[klass alloc] initWithJSONObject:someJSONObjects[idx]]];
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
  var clown = [[[self class] alloc] initWithJSONObject:_json];
  [clown cloneFromObj:self];
  return clown;
}

- (void)cloneFromObj:(PageElement)obj
{
  // Called by clone and should be overwritten by subclasses to copy data that
  // is not contained in the JSON (_json) object that is being represented by this
  // object.
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

- (void)removeFromServer
{
  [[CommunicationManager sharedInstance] deleteElement:self];
}

- (void)removeFromSuperview
{
  [_mainView removeFromSuperview];
}

- (void)addToServer
{
  [[CommunicationManager sharedInstance] addElement:self];
}

- (void)updateServer
{
  [[CommunicationManager sharedInstance] updateElement:self];
}

- (void)generateViewForDocument:(CPView)container
{
  // this needs to be implemented by the subclass.
}

- (PageElement) setLocation:(CGRect)aLocation
{
  x      = aLocation.origin.x;
  y      = aLocation.origin.y;
  width  = aLocation.size.width;
  height = aLocation.size.height;
  return self;
}

- (CGRect) location
{
  return CGRectMake(x, y, width, height);
}

- (void)requestCompleted:(CPObject)data
{
  CPLogConsole("[PM DATA SOURCE] request completed with " + data);

  switch ( data.action ) {
  case "page_elements_create":
    if ( data.status == "ok" ) {
      page_element_id = data.page_element_id;
    }
    CPLogConsole([self pageElementId], "create action: " + data.status, "[PM DATA SRC]");
    break;
  case "page_elements_resize":
    CPLogConsole(data.status, "resize action", "[PM DATA SRC]");
    break;
  case "page_elements_update":
    CPLogConsole(data.status, "update action", "[PM DATA SRC]");
    break;
  case "page_elements_destroy":
    CPLogConsole(data.status, "delete action", "[PM DATA SRC]");
    [[DocumentViewController sharedInstance] removeObject:self];
    break;
  }
}

@end
