/*
 * A PageElement. What does it do? It's responsible for communicating with the server
 * and inform it that something changed with a specific subclass. This means that a 
 * PageElement is a general representation of a specific (e.g. Image, Facebook Image, etc)
 * object contained in a document. This generalisation means that the subclass don't need
 * communicate directly with the server and don't need to send over their position nor size
 * to the server.
 *
 * How does an PageElement come to life? There are three creational events in the life of
 * a PageElement:
 *
 *  1. It's created as part of a drag operation from an external source. Example: facebook.j
 *     Here the PageElement is initialized via a json object that came from the external
 *     service and contains all the necessary data to initialize the object. The object
 *     can initialize instance variables that are sent to the server automagically (see
 *     flickr.j for an example).
 *  2. As part of the drop operation(*) a PageElement is retrieved from the DragDropManager
 *     and is cloned via cloneForDrop. This fairly simple operation and subclasses don't
 *     need to do anything special.
 *  3. Editing an existing publication requires that PageElements are initialized via
 *     json sent from the backend server. This is done by sending (for elements that come
 *     from external sources) to construct (on the server side) a json object that looks 
 *     just the same as the one used to initialize the object from the external source.
 *     For tool elements, i.e. things that we create ourself, we use the format that we
 *     have stored on the server. 
 *
 * *=Drag&Drop's are managed over the DragDropManager, hence there is a "drag" operation
 *   and a drop operation. See drag_drop_manager.j for details.
 */

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
  JSObject _json;

  // We split the location up since it's then set over the wire automagically and a
  // CGSize object is not split when serialized to json.
  float x;
  float y;
  float width;
  float height;
  int   page_element_id;

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
    // reverse order since we're going from the back.
    [objects insertObject:[[klass alloc] initWithJSONObject:someJSONObjects[idx]] atIndex:0];
  }
  return objects;
}

// The array contains a bunch of PageElements from the server, this means they contain 
// size information and the class of the actual page element. This means, we store
// the size+location information and delegate the rest to the specific object.
+ (CPArray) createObjectsFromServerJson:(CPArray)someJSONObjects 
{
  var objects = [[CPArray alloc] init],
    idx = someJSONObjects.length;
  while ( idx-- ) {
    var jsonObj = someJSONObjects[idx];
    // TODO should really check the type and ensure that it's supported -- not that someone
    // TODO sends an incorrect type ....
    var object = [[CPClassFromString(jsonObj._type) alloc] initWithJSONObject:jsonObj._json];
    object.x               = jsonObj.x;
    object.y               = jsonObj.y;
    object.width           = jsonObj.width;
    object.height          = jsonObj.height;
    object.page_element_id = jsonObj.id;
    [objects insertObject:object atIndex:0];
  }

  CPLogConsole("[PgEl] Found " + [objects count] + " page elements");
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

// Called when the page element is dropped into a DocumentView. Subclass can override
// the cloneForDropFromObj method to do specific copying but it should not be necessary.
// It would only be necessary if a PageElement had some data that is not stored in the _json
// object.
- (CPObject)cloneForDrop
{
  var clown = [[[self class] alloc] initWithJSONObject:_json];
  [clown cloneForDropFromObj:self];
  return clown;
}

- (void)cloneForDropFromObj:(PageElement)obj
{
  // Called by clone and should be overwritten by subclasses to copy data that
  // is not contained in the JSON (_json) object that is being represented by this
  // object.
}

// This is the ID that our backend server has given to this object. It is only
// set once when have an ok from the server for adding this object to the document.
// See requestCompleted here for details.
- (int) pageElementId
{
  return page_element_id;
}

// This needs to be implemented by the subclass and provides a unique id _string_
// across all objects of the same class. This is normally the id used by the
// DataSource provider, i.e. Twitter, Flickr, etc. An id can be the same between
// two different data sources but needs to be unique to the same service.
- (CPString) id_str
{
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
  // *** This needs to be implemented by the subclass ***
  //
  // It gets called once the element gets placed into the DocumentView, i.e. the publicatoin.
  // It should render a nice view for the publication. The subclass should use the _mainView
  // instance variable so that this class can handle removing the individual subclasses from
  // DocumentView -- see removeFromSuperview here.
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

// Callback once an Ajax call returns. Here we could capture failures and store them
// (somewhere else) to be redone at a later date -- but this logic is beyond the scope
// of the current development cycle.
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
    if ( data.status == "ok" ) {
      [[DocumentViewController sharedInstance] removeObject:self];
    }
    break;
  }
}

@end
