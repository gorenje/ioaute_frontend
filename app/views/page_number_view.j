@implementation PageNumberView : CPCollectionView

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
