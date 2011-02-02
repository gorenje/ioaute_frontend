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

  CGSize initialSize @accessors;
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
    initialSize = CGSizeMake(150,150);
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

- (void)sendResizeToServer
{
  [[CommunicationManager sharedInstance] resizeElement:self];
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

// Does this page element have extra properties that can be set via a properties
// dialog? Default is no and each specific page element that does needs to override
// this method and provide a list of properties via getProperties.
- (BOOL) hasProperties
{
  return NO;
}

- (void)openProperyWindow
{
}

// State handling to support (limited) undo/redo. Should store the current state
// (i.e. all instance variables) onto the state-stack. The very first one is retrieved
// and the state is restored from that one in the case of a pop. The state container is
// thrown out are restoring the state.
//
// TODO needs implementation!
- (void)pushState
{
}

- (void)popState
{
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

// This provides support for color specification BUT only the functionality, the instance
// variables that are used MUST be defined by the subclass. In order to make use of these
// methods, need to define the following instance variables:
//
//     int m_red;
//     int m_blue;
//     int m_green;
//     float m_alpha;
//     CPColor m_color;
//
// the reason we don't define the instance variables is that not all PageElements need
// a color and having the instance varibales here would mean that they are *always* sent
// to the server, even if the specific page element does not support color.
//
// Hence we only provide the functionality and if a specific page elemnt does
// have color, then it can use the functionality and define the instance varibales.
@implementation PageElement (ColorSupport)

// assume that the _json object has already been set.
- (void)setColorFromJson 
{
  m_red   = _json.red;
  m_blue  = _json.blue;
  m_green = _json.green;
  m_alpha = _json.alpha;
  m_color = [self createColor];
}

- (void)setColor:(CPColor)aColor
{
  m_color = aColor;
  m_red   = Math.round([aColor redComponent] * 255);
  m_green = Math.round([aColor greenComponent] * 255);
  m_blue  = Math.round([aColor blueComponent] * 255);
  m_alpha = [aColor alphaComponent];
}

- (CPColor)getColor
{
  return m_color;
}

- (CPColor)createColor
{
  return [CPColor colorWith8BitRed:m_red green:m_green blue:m_blue alpha:m_alpha];
}

@end

// ---------------------------------------------------------------------------------
@implementation PageElement (SizeSupport)

- (void)setSize:(CGSize)aSize
{
  width = aSize.width;
  height = aSize.height;
}

- (void)setFrameSize:(CGSize)aSize
{
  [self setSize:aSize];
  // this gets picked up by the document view cell editor view if there is one for this
  // page element. It resizes everything else. If there isn't a document view editor, then
  // the document is not updated by the server will (probably via a call to sendResizeToServer).
  [[CPNotificationCenter defaultCenter] 
    postNotificationName:PageElementDidResizeNotification
                  object:self];
}

- (CGSize)getSize
{
  return CGSizeMake(width, height);
}

@end

// ================================================================================
// To use the font support, have the following instance variables:
//    float m_fontSize;
//    CPString m_fontName;
//    CPString m_fontStyle;
// and after that you can use the following functionality.
@implementation PageElement (FontSupport)

- (void)setFontFromJson
{
  m_fontSize  = _json.font_size;
  m_fontName  = _json.font_name;
  // TODO support more features, basically everything that is configurable in CPFont.j
  // m_fontStyle = _json.font_style;
  [self _setFont];
}

- (void)_setFont
{
  if ( !m_fontSize ) m_fontSize = 12;
  if ( m_fontName ) {
    m_fontObj = [CPFont fontWithName:m_fontName size:m_fontSize];
  } else {
    m_fontObj = [CPFont systemFontOfSize:m_fontSize]
  }
}

- (float) getFontSize
{
  return m_fontSize;
}

- (CPString) getFontName
{
  return m_fontName;
}

- (void)setFontSize:(float)value
{
  m_fontSize = value;
  [self _setFont];
  [_mainView setFont:m_fontObj];
}

- (void)setFontName:(CPString)aName
{
  m_fontName = aName;
  [self _setFont];
  [_mainView setFont:m_fontObj];
}

- (void)setFont:(CPFont)aFont
{
  m_fontSize = [aFont size];
  m_fontName = [aFont familyName];
  m_fontObj  = aFont;
  [_mainView setFont:m_fontObj];
}

@end
