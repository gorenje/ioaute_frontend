/*
 * Two mixins to allow either for a snap-to-grid value or not.
 * They just override the mousedragged method for the document view cell.
 */
@implementation DocumentViewCellWithoutSnapgrid : MixinHelper

- (void)mouseDragged:(CPEvent)anEvent
{
  var location = [anEvent locationInWindow],
    origin = [self frame].origin;

  var frame_origin = CGPointMake(origin.x + location.x - dragLocation.x, 
                                 origin.y + location.y - dragLocation.y);

  [self setFrameOrigin:frame_origin];
  if ( self == [[DocumentViewEditorView sharedInstance] documentViewCell] ) {
    var hiLightOrigin = [[DocumentViewEditorView sharedInstance] frame].origin;
    [[DocumentViewEditorView sharedInstance] 
          setFrameOrigin:CGPointMake(hiLightOrigin.x + location.x - dragLocation.x, 
                                     hiLightOrigin.y + location.y - dragLocation.y)];
  }
  dragLocation = location;
}

@end

/*!
  Snapgrid has been activated and this handles mouse drag from now on.
*/
@implementation DocumentViewCellWithSnapgrid : MixinHelper

- (void)mouseDragged:(CPEvent)anEvent
{
  var location = [anEvent locationInWindow],
    origin = [self frame].origin;

  // step_* is used to ensure that the cell is only moved in units of the snap grid size
  var step_x = ( parseInt((location.x - dragLocation.x) / SnapGridSpacingSize,10) * 
                 SnapGridSpacingSize);
  var step_y = ( parseInt((location.y - dragLocation.y) / SnapGridSpacingSize,10) * 
                 SnapGridSpacingSize);

  // min_step_* is used to move the cell onto the SnapGrid boundary
  var min_step_x = origin.x % SnapGridSpacingSize;
  min_step_x = ( min_step_x > 0 ? SnapGridSpacingSize - min_step_x : 
                 ( min_step_x < 0 ? SnapGridSpacingSize + min_step_x : 0));
  var min_step_y = origin.y % SnapGridSpacingSize;
  min_step_y = ( min_step_y > 0 ? SnapGridSpacingSize - min_step_y : 
                 ( min_step_y < 0 ? SnapGridSpacingSize - min_step_y : 0));

  // only set the dragLocation to the current location if we actually moved the cell.
  if ( step_x != 0 || min_step_x != 0 || step_y != 0 || min_step_y != 0 ) {
    [self setFrameOrigin:CGPointMake(origin.x + step_x + min_step_x, 
                                     origin.y + step_y + min_step_y)];
    if ( self == [[DocumentViewEditorView sharedInstance] documentViewCell] ) {
      var hiLightOrigin = [[DocumentViewEditorView sharedInstance] frame].origin;
      [[DocumentViewEditorView sharedInstance] 
          setFrameOrigin:CGPointMake(hiLightOrigin.x + step_x + min_step_x, 
                                     hiLightOrigin.y + step_y + min_step_y)];
    }
    dragLocation = location;
  }
}

@end
