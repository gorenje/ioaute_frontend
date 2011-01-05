/*
 * This is basically a collection view with item resize and no automatic layout.
 * Hence some of this code is stolen from CPCollectionView.
 */
@import <Foundation/CPObject.j>

var DropHighlight = [CPColor colorWith8BitRed:230 green:230 blue:250 alpha:1.0];

@implementation DocumentView : CPView
{
  CPArray                 _content;
  CPArray                 _items;
  CPData                  _itemData;
  CPCollectionViewItem    _itemPrototype;
  CPMutableArray          _cachedItems;
}

- (id)initWithFrame:(CGRect)aFrame
{
    self = [super initWithFrame:aFrame];

    if (self)
    {
      var documentItem = [[CPCollectionViewItem alloc] init];
      [documentItem setView:[[DocumentViewCell alloc] 
                              initWithFrame:CGRectMake(0, 0, 150, 150)]];
      [self setItemPrototype:documentItem];
      [self registerForDraggedTypes:[TweetDragType, FlickrDragType, FacebookDragType, 
                                                  YouTubeDragType, ToolElementDragType]];
      //[self setAutoresizingMask:(CPViewWidthSizable | CPViewHeightSizable)];
      [self setAutoresizingMask:CPViewNotSizable];

      [self setAutoresizesSubviews:NO];
      [self setBackgroundColor:[CPColor whiteColor]];
      CPLogConsole( "[DOC VIEW] Done initialisation" );
    }
    return self;
}

- (void)setItemPrototype:(CPCollectionViewItem)anItem
{
  if ( !_items )    _items = [];
  if ( !_content )  _content = [];

  _cachedItems     = [];
  _itemData        = nil;
  _itemPrototype   = anItem;

  [self reloadContent];
}

- (void)postContentChangeNotification
{
  [[CPNotificationCenter defaultCenter] 
    postNotificationName:DocumentViewContentDidChangeNotification
                  object:self];
}

- (void)setContent:(CPArray)objects
{
  _content = objects;
  [self postContentChangeNotification];
  [self reloadContent];
}

- (void)addToContent:(CPArray)objects atLocation:(CPPoint)aLocation
{
  if ( !_content ) _content = [];
  if ( !_items )   _items = [];
  var location = [self convertPoint:aLocation fromView:nil];

  for ( var idx = 0; idx < [objects count]; idx++ ) {
    _content.push(objects[idx]);
    var item = [self newItemForRepresentedObject:objects[idx]];
    var view = [item view];
    _items.push(item);
    [self addSubview:view];
    var origin = CGPointMake(location.x - CGRectGetWidth([view frame]) / 2.0, 
                             location.y - CGRectGetHeight([view frame]) / 2.0);
    [view setFrameOrigin:origin];
  }
  // TODO not sure whether this is needed.
  // [[self superview] setNeedsDisplay:YES];
  [self postContentChangeNotification];
}

- (CPArray)content
{
  return _content;
}

- (void)reloadContent
{
  var count = _items.length;
  while (count--) {
    [[_items[count] view] removeFromSuperview];
    [_items[count] setSelected:NO];

    _cachedItems.push(_items[count]);
  }

  _items = [];

  if (!_itemPrototype || !_content)
    return;

  var index = 0;
  count = _content.length;

  for (; index < count; ++index) {
    _items.push([self newItemForRepresentedObject:_content[index]]);
    [self addSubview:[_items[index] view]];
  }
}

- (CPCollectionViewItem)newItemForRepresentedObject:(id)anObject
{
  var item = nil;
  if (_cachedItems.length) {
    item = _cachedItems.pop();
  } else {
    if ( !_itemData && _itemPrototype )
      _itemData = [CPKeyedArchiver archivedDataWithRootObject:_itemPrototype];
    item = [CPKeyedUnarchiver unarchiveObjectWithData:_itemData];
  }

  [item setRepresentedObject:anObject];
  return item;
}


// 
// Drag&drop callbacks.
//
- (void)performDragOperation:(CPDraggingInfo)aSender
{
  CPLogConsole("peforming drag operations @ collection view");
  var modelObjs = [self obtainModelObjects:aSender];
  [[DocumentViewEditorView sharedInstance] setDocumentViewCell:nil]; // hide editor highlight
  // clone before storing, the drag objects are assumed to be "representations" 
  // and are/might-be/will-be reused in future drag operations.
  for ( var idx = 0; idx < modelObjs.length; idx++ ) {
    modelObjs[idx] = [modelObjs[idx] clone];
  }
  [self addToContent:modelObjs atLocation:[aSender draggingLocation]];
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
  var data = [[aSender draggingPasteboard] dataForType:TweetDragType];
  if ( data ) {
    return [self dropHandleTweets:data];
  } else {
    data = [[aSender draggingPasteboard] dataForType:FlickrDragType];
    if ( data ) {
      return [self dropHandleFlickr:data];
    } else {
      data = [[aSender draggingPasteboard] dataForType:FacebookDragType];
      if ( data ) {
        return [self dropHandleFacebook:data];
      } else {
        data = [[aSender draggingPasteboard] dataForType:ToolElementDragType];
        if ( data ) {
          return [self dropHandleToolElement:data];
        }
      }
    }
  }
  return [];
}

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
