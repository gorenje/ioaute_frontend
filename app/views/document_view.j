/*
 * Created by Gerrit Riessen
 * Copyright 2010-2011, Gerrit Riessen
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */

/*
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
     @selector(dropHandleTweets:),        TweetDragType,
     @selector(dropHandleFlickr:),        FlickrDragType,
     @selector(dropHandleFacebook:),      FacebookDragType,
     @selector(dropHandleGoogleImages:),  GoogleImagesDragType,
     @selector(dropHandleYouTubeVideos:), YouTubeDragType,
     @selector(dropHandleToolElement:),   ToolElementDragType];

var DragDropHandlersKeys = [DragDropHandlers allKeys];
var DropHighlight = [CPColor colorWith8BitRed:230 green:230 blue:250 alpha:1.0];

@implementation DocumentView : CPView
{
  DocumentViewController  _controller;
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];

  if (self)
  {
    _controller = [DocumentViewController sharedInstance];

    [DocumentViewCellWithoutSnapgrid addToClass:DocumentViewCell];
    [self registerForDraggedTypes:DragDropHandlersKeys];
    [self setAutoresizingMask:CPViewNotSizable];
    [self setAutoresizesSubviews:NO];
    [self setBackgroundColor:[CPColor whiteColor]];
  }
  return self;
}

- (void)mouseDown:(CPEvent)anEvent
{
  [[DocumentViewEditorView sharedInstance] setDocumentViewCell:nil];
}

- (DocumentViewCell)newItemForRepresentedObject:(id)anObject
{
  return [[DocumentViewCell alloc] initWithPageElement:anObject];
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

  // sort the objects by zIndex so that they are layered correctly.
  [objects sortUsingSelector:@selector(compareZ:)];
  var idx = [objects count];
  while ( idx-- ) {
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
- (CPArray)addObjectsToView:(CPArray)objects atLocation:(CPPoint)aLocation
{
  var location = [self convertPoint:aLocation fromView:nil];
  var result = [CPArray array];

  for ( var idx = 0; idx < [objects count]; idx++ ) {
    var item = [self newItemForRepresentedObject:objects[idx]];
    var view = [item view];
    // setup the location of the new view
    var origin = CGPointMake(location.x - CGRectGetWidth([view frame]) / 2.0, 
                             location.y - CGRectGetHeight([view frame]) / 2.0);

    [view setFrameOrigin:origin];
    [view setFrameSize:[objects[idx] initialSize]];

    [objects[idx] setLocation:[view frame]];
    // TODO need to set the zIndex of the object ....
    [objects[idx] setZIndex:[[DocumentViewController sharedInstance] nextZIndex]];

    // once the location is set, we can add it to ourselves.
    [self addSubview:view];
    result.push(view);
  }
  return result;
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
    [self setBackgroundColor:[[[PageViewController sharedInstance] 
                                currentPageObj] getColor]];
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
  return [DocumentView _retrieveObjectsWithSelector:@selector(flickrImageForId:)
                                          usingData:data];
}

- (CPArray) dropHandleTweets:(CPArray)data
{
  return [DocumentView _retrieveObjectsWithSelector:@selector(tweetForId:)
                                          usingData:data];
}

- (CPArray) dropHandleFacebook:(CPArray)data
{
  return [DocumentView _retrieveObjectsWithSelector:@selector(facebookItemForId:)
                                          usingData:data];
}

- (CPArray)dropHandleToolElement:(CPArray)data
{
  return [DocumentView _retrieveObjectsWithSelector:@selector(toolElementForId:)
                                          usingData:data];
}

- (CPArray)dropHandleGoogleImages:(CPArray)data
{
  return [DocumentView _retrieveObjectsWithSelector:@selector(googleImageForId:)
                                          usingData:data];
}

- (CPArray)dropHandleYouTubeVideos:(CPArray)data
{
  return [DocumentView _retrieveObjectsWithSelector:@selector(youTubeVideoForId:)
                                          usingData:data];
}

+ (CPArray) _retrieveObjectsWithSelector:(SEL)aSelector usingData:(CPArray)data
{
  data = [CPKeyedUnarchiver unarchiveObjectWithData:data];
  var objects = [];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    var obj = [[DragDropManager sharedInstance] 
                performSelector:aSelector withObject:data[idx]];
    if ( obj ) [objects addObject:obj];
  }
  return objects;
}

@end
