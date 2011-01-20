/*
 * This is basically a collection view with item resize and no automatic layout.
 * Hence some of this code is stolen from CPCollectionView. 
 * There is also a second reason for this view being here: Drag&Drop. D&D is not
 * delegated to a controller or something else, instead, if you want D&D, you'll need
 * to subclass CPView and implement performDragOperation (i.e. all D&D callbacks).
 */

/*
 * Lookup table for drag types to handlers. The handlers are defined below and
 * the drag types are global constants defined in AppController.j
 * Note: the value-key orientation, not key-value ... (for those from ruby)
 */
var DragDropHandlers = 
  [CPDictionary dictionaryWithObjectsAndKeys:
                  @selector(dropHandleTweets:),      TweetDragType,
                  @selector(dropHandleFlickr:),      FlickrDragType,
                  @selector(dropHandleFacebook:),    FacebookDragType,
                  @selector(dropHandleToolElement:), ToolElementDragType];

var DragDropHandlersKeys = [DragDropHandlers allKeys];
var DropHighlight = [CPColor colorWith8BitRed:230 green:230 blue:250 alpha:1.0];

@implementation DocumentView : CPView
{
  CPData                  _itemData;
  CPCollectionViewItem    _itemPrototype;
  DocumentViewController  _controller;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
      _itemData          = nil;
      _controller        = [DocumentViewController sharedInstance];
      _itemPrototype     = [[CPCollectionViewItem alloc] init];

      [_itemPrototype setView:[[DocumentViewCell alloc] 
                                initWithFrame:CGRectMake(0, 0, 150, 150)]];

      [self registerForDraggedTypes:DragDropHandlersKeys];
      //[self setAutoresizingMask:(CPViewWidthSizable | CPViewHeightSizable)];
      [self setAutoresizingMask:CPViewNotSizable];

      [self setAutoresizesSubviews:NO];
      [self setBackgroundColor:[CPColor whiteColor]];

      CPLogConsole( "[DOC VIEW] Done initialisation" );
    }
    return self;
}

//
// Item Prototype and generating views for the page element objects that we store.
//
- (CPCollectionViewItem)newItemForRepresentedObject:(id)anObject
{
  if ( !_itemData && _itemPrototype )
    _itemData = [CPKeyedArchiver archivedDataWithRootObject:_itemPrototype];

  var item = [CPKeyedUnarchiver unarchiveObjectWithData:_itemData];
  [item setRepresentedObject:anObject];
  return item;
}

//
// Content handling stuff.
//

// This is used to "reset" the content after a page change. The objects all have
// previous locations and sizes, these need to be used to setup the views.
- (void)setContent:(CPArray)objects
{
  var subviews_to_remove = [self subviews];
  for ( var idx = 0; idx < subviews_to_remove.length; idx++ ){
    [subviews_to_remove[idx] removeFromSuperview];
  }
  if (!objects) return;

  for ( var idx = 0; idx < [objects count]; idx++ ) {
    var item = [self newItemForRepresentedObject:objects[idx]];
    var view = [item view];
    // setup the location of the new view
    [view setFrame:[objects[idx] location]];
    // once the location is set, we can add it to ourselves.
    [self addSubview:view];
  }
}

// exclusively used for adding *new* dragged objects, none of these objects
// are assumed to have a location, therefore it's set for the objects.
- (void)addObjectsToView:(CPArray)objects atLocation:(CPPoint)aLocation
{
  var location = [self convertPoint:aLocation fromView:nil];

  for ( var idx = 0; idx < [objects count]; idx++ ) {
    var item = [self newItemForRepresentedObject:objects[idx]];
    var view = [item view];
    // setup the location of the new view
    var origin = CGPointMake(location.x - CGRectGetWidth([view frame]) / 2.0, 
                             location.y - CGRectGetHeight([view frame]) / 2.0);
    [view setFrameOrigin:origin];

    CPLogConsole( "[DV] addObjects to Origin view: x: " + origin.x + " y: " + origin.y );
    CPLogConsole( "[DV] addObjects to view: x: " + [view frame].origin.x + " y: " + [view frame].origin.y );
    [objects[idx] setLocation:[view frame]];
    // once the location is set, we can add it to ourselves.
    [self addSubview:view];
  }
}

// 
// Drag&drop callbacks.
//
- (void)performDragOperation:(CPDraggingInfo)aSender
{
  CPLogConsole("peforming drag operations @ collection view");
  var modelObjs = [self obtainModelObjects:aSender];
  // hide editor highlight
  [[DocumentViewEditorView sharedInstance] setDocumentViewCell:nil]; 

  // clone before storing, the drag objects are assumed to be "representations" 
  // and are/might-be/will-be reused in future drag operations.
  for ( var idx = 0; idx < modelObjs.length; idx++ ) {
    modelObjs[idx] = [modelObjs[idx] cloneForDrop];
  }
  [_controller draggedObjects:modelObjs atLocation:[aSender draggingLocation]];
  [self setHighlight:NO];
}

- (void)draggingEntered:(CPDraggingInfo)aSender
{
  [self setHighlight:YES];
}

- (void)draggingExited:(CPDraggingInfo)aSender
{
  [self setHighlight:NO];
}

/*
 * Called to highlight the document view when a drag is available or remove highligh
 * if the drag moved out of the view.
 */
- (void)setHighlight:(BOOL)flag
{
  if ( flag ) {
    [self setBackgroundColor:DropHighlight];
  } else {
    [self setBackgroundColor:[CPColor whiteColor]];
  }
}

//
// Drag&drop helpers and handlers.
//
- (CPArray)obtainModelObjects:(CPDraggingInfo)aSender
{
  var data = nil, dragType = nil;
  for ( var idx = 0; idx < [DragDropHandlersKeys count]; idx++ ) {
    dragType = DragDropHandlersKeys[idx];
    data = [[aSender draggingPasteboard] dataForType:dragType];
    if ( data ) {
      return [self performSelector:[DragDropHandlers objectForKey:dragType]
                        withObject:data];
    }
  }
  return [];
}

// 
// From here on end, Drag handlers....
//
- (CPArray) dropHandleFlickr:(CPArray)data
{
  data = [CPKeyedUnarchiver unarchiveObjectWithData:data];
  var objects = [];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    var obj = [[DragDropManager sharedInstance] flickrImageForId:data[idx]];
    if ( obj ) {
      [objects addObject:obj];
    } else {
      CPLogConsole( "FlickrImage was nil, not available for : " + data[idx]);
    }
  }
  return objects;
}

- (CPArray) dropHandleTweets:(CPArray)data
{
  data = [CPKeyedUnarchiver unarchiveObjectWithData:data];
  var objects = [];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    var obj = [[DragDropManager sharedInstance] tweetForId:data[idx]];
    if ( obj ) {
      [objects addObject:obj];
    } else {
      CPLogConsole( "Tweet was nil, not available for : " + data[idx]);
    }
  }
  return objects;
}

- (CPArray) dropHandleFacebook:(CPArray)data
{
  data = [CPKeyedUnarchiver unarchiveObjectWithData:data];
  var objects = [];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    var obj = [[DragDropManager sharedInstance] facebookItemForId:data[idx]];
    if ( obj ) {
      [objects addObject:obj];
    } else {
      CPLogConsole( "Facebook was nil, not available for : " + data[idx]);
    }
  }
  return objects;
}

- (CPArray)dropHandleToolElement:(CPArray)data
{
  data = [CPKeyedUnarchiver unarchiveObjectWithData:data];
  var objects = [];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    var obj = [[DragDropManager sharedInstance] toolElementForId:data[idx]];
    if ( obj ) {
      [objects addObject:obj];
    } else {
      CPLogConsole( "Toolelement was nil, not available for : " + data[idx]);
    }
  }
  return objects;
}

@end
