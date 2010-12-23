/*
 * This is basically a collection view with item resize and no automatic layout.
 * Hence some of this code is stolen from CPCollectionView.
 */
@import <Foundation/CPObject.j>

@implementation DocumentView : CPView
{
  CPArray                 _content;
  CPArray                 _items;
  CPData                  _itemData;
  CPCollectionViewItem    _itemPrototype;
  CPCollectionViewItem    _itemForDragging;
  CPMutableArray          _cachedItems;
}

- (void)awakeFromCib
{
  CPLogConsole( "setting document controller as delegate" );
  [self registerForDraggedTypes:[TweetDragType, FlickrDragType]];

  var documentItem = [[CPCollectionViewItem alloc] init];
  [documentItem setView:[[DocumentViewCell alloc] initWithFrame:CGRectMake(0, 0, 150, 150)]];
  _itemPrototype = documentItem;

  CPLogConsole( "Done setting document controller as delegate" );
}

- (void)keyDown:(CPEvent)anEvent
{
  CPLogConsole( "[DOCUMENT VIEW] Key dwon: " + [anEvent keyCode]);
}

- (void)setItemPrototype:(CPCollectionViewItem)anItem
{
  if ( !_items )
    _items = [];
  if ( !_content ) 
    _content = [];

  _cachedItems = [];
  _itemData = nil;
  _itemForDragging = nil;
  _itemPrototype = anItem;

  [self reloadContent];
}

- (void)setContent:(CPArray)objects
{
  _content = objects;
  [self reloadContent];
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
// The magic of drag&drop
//
- (void)performDragOperation:(CPDraggingInfo)aSender
{
  CPLogConsole("peforming drag operations @ collection view");
  var modelObjs = [];

  var data = [[aSender draggingPasteboard] dataForType:TweetDragType];
  if ( data ) {
    CPLogConsole("[DOCUMENT VIEW] found tweet drag data");
    modelObjs = [self dropHandleTweets:data];
  } else {
    data = [[aSender draggingPasteboard] dataForType:FlickrDragType];
    if ( data ) {
      CPLogConsole("[DOCUMENT VIEW] found flickr drag data");
      modelObjs = [self dropHandleFlickr:data];
    }
  }

  var existingContent = [self content];
  if ( existingContent ) {
    for ( var idx = 0; idx < [existingContent count]; idx++ ) {
      [modelObjs addObject:existingContent[idx]];
    }
  }
  
  [[DocumentViewEditorView sharedInstance] setDocumentViewCell:nil]; // hide editor highlight
  [self setContent:modelObjs];
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
    [self setBackgroundColor:[CPColor redColor]];
  } else {
    [self setBackgroundColor:[CPColor blueColor]];
  }
}

- (CPArray) dropHandleFlickr:(CPArray)data
{
  data = [CPKeyedUnarchiver unarchiveObjectWithData:data];
  var objects = [];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    var obj = [[DragDropManager sharedInstance] flickrImageForId:data[idx]];
    if ( obj ) {
      CPLogConsole( "Found FlickrImage : " + data[idx]);
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
      CPLogConsole( "Tweet text: " + [obj text] );
      [objects addObject:obj];
    } else {
      CPLogConsole( "Tweet was nil, not available for : " + data[idx]);
    }
  }
  return objects;
}

@end
