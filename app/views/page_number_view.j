@implementation PageNumberView : CPCollectionView
{
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];
  if ( self ) {
    [self registerForDraggedTypes:[PageNumberDragType]];
  }
  return self;
}

- (void)performDragOperation:(CPDraggingInfo)aSender
{
  CPLogConsole( "[PNV] index of drop location: " + [self indexAtLocation:[aSender draggingLocation]]);

//   var modelObjs = [self obtainModelObjects:aSender];
//   // hide editor highlight
//   [[DocumentViewEditorView sharedInstance] setDocumentViewCell:nil]; 

//   // clone before storing, the drag objects are assumed to be "representations" 
//   // and are/might-be/will-be reused in future drag operations.
//   for ( var idx = 0; idx < modelObjs.length; idx++ ) {
//     modelObjs[idx] = [modelObjs[idx] cloneForDrop];
//   }
//   [_controller draggedObjects:modelObjs atLocation:[aSender draggingLocation]];
//   [self setHighlight:NO];
}

// Return the index of the page that is closest to the current dragging location
- (int)indexAtLocation:(CGPoint)aDraggingLocation
{
  var aLocation = [self convertPoint:aDraggingLocation
                            fromView:[[[CPApplication sharedApplication] mainWindow] 
                                       contentView]];
  var allPages = [self content];
  for ( var idx = 0; idx < [allPages count]; idx++ ) {
    if ( CGRectContainsPoint( [self rectForItemAtIndex:idx], aLocation ) ) {
      return idx;
    }
  }
  return -1;
}


@end
