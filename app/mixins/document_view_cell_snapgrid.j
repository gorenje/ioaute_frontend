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

/*!
  Two mixins to allow either for a snap-to-grid value or not.
  They just override the mousedragged method for the document view cell.
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
  var location    = [anEvent locationInWindow],
    origin        = [self frame].origin,
    snapgridwidth = [[[ConfigurationManager sharedInstance] pubProperties] snapGridWidth];

  // step_* is used to ensure that the cell is only moved in units of the snap grid size
  var step_x = ( parseInt((location.x - dragLocation.x) / snapgridwidth,10) * 
                 snapgridwidth);
  var step_y = ( parseInt((location.y - dragLocation.y) / snapgridwidth,10) * 
                 snapgridwidth);

  // min_step_* is used to move the cell onto the SnapGrid boundary
  var min_step_x = origin.x % snapgridwidth;
  min_step_x = ( min_step_x > 0 ? snapgridwidth - min_step_x : 
                 ( min_step_x < 0 ? snapgridwidth + min_step_x : 0));
  var min_step_y = origin.y % snapgridwidth;
  min_step_y = ( min_step_y > 0 ? snapgridwidth - min_step_y : 
                 ( min_step_y < 0 ? snapgridwidth - min_step_y : 0));

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
