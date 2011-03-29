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
@implementation DocumentViewCell : GRRotateView
{
  CGPoint  dragLocation;
  CGPoint  editedOrigin;

  // This is a reference to the a PageElement object and is basically the delegate
  // for certain events (e.g. moving or resize or deletion ...)
  PageElement representedObject @accessors(property=pageElement,readonly);
}

- (id)initWithPageElement:(PageElement)aPageElement
{
  self = [super initWithFrame:CGRectMake(0, 0, 5, 5)];
  if ( self ) {
    [self setRepresentedObject:aPageElement];
  }
  return self;
}

- (CPView)view
{
  return self;
}

/*
 * Set from DocumentView to draw a new object (object being a PageElement object).
 */
- (void)setRepresentedObject:(CPObject)anObject
{
  if ( representedObject ) {
    [representedObject removeFromSuperview];
    [self removeNotificationListener];
  }
  representedObject = anObject;
  [representedObject generateViewForDocument:self];
  [self setupNotificationListener];

  var rotation = 0;
  if ( [representedObject respondsToSelector:@selector(rotation)] ) {
    rotation = [representedObject rotationRadians];
  }
  [self setRotation:rotation];
}

- (void)setSelected:(BOOL)flag
{
  [[DocumentViewEditorView sharedInstance] setDocumentViewCell:self];
}

- (void)setupNotificationListener
{
  [[CPNotificationCenter defaultCenter] 
    addObserver:self
       selector:@selector(pageElementSuicide:)
              name:PageElementWantsToBeDeletedNotification
            object:representedObject];

  [[CPNotificationCenter defaultCenter] 
    addObserver:self
       selector:@selector(pageElementDidRotate:)
           name:PageElementDidRotateNotification
         object:representedObject];
}

- (void)removeNotificationListener
{
  [[CPNotificationCenter defaultCenter] 
    removeObserver:self
              name:PageElementWantsToBeDeletedNotification
            object:representedObject];

  [[CPNotificationCenter defaultCenter] 
    removeObserver:self
              name:PageElementDidRotateNotification
            object:representedObject];
}

- (void)pageElementSuicide:(CPNotification)aNotification
{
  [self deleteFromPage];
}

- (void)pageElementDidRotate:(CPNotification)aNotification
{
  [self setRotation:[[aNotification object] rotationRadians]];
}

/*
 * Message sent from the DocumentViewEditor to remove a page element.
 */
- (void)deleteFromPage
{
  if ( representedObject ) {
    [representedObject removeFromSuperview];
    [representedObject removeFromServer];
    representedObject = nil;
  }
  [self removeFromSuperview];
}

- (void)cloneAndAddToPage
{
  if ( representedObject ) {
    [[CommunicationManager sharedInstance] 
      copyElement:representedObject];
  }
}

//
// Callbacks for the editor view -- this is resize.
//
- (void)willBeginLiveResize
{
}

- (void)didEndLiveResize
{
  [self sendResizeToServer];
}

- (void)doResize:(CGRect)aRect
{
  [self setFrameSize:aRect.size];
  [self setFrameOrigin:aRect.origin];
  [self setNeedsDisplay:YES];
}

//
// Handle moving an element to somewhere else.
//
- (void)mouseDown:(CPEvent)anEvent
{
  [self setSelected:YES];
  [[CPCursor closedHandCursor] set];
  editedOrigin = [self frame].origin;
  dragLocation = [anEvent locationInWindow];
}

/*
  NOTE: The mouseDragged method, is defined in the mixin
  NOTE:   mixins/document_view_cell_snapgrid.j
  NOTE: and depends on whether a snapgrid is defined or not.
*/

- (void)mouseUp:(CPEvent)anEvent
{
  [[CPCursor arrowCursor] set];
  [self setSelected:NO];
  [self setFrameOrigin:[self frame].origin];
  [self sendResizeToServer];
}

- (void)setZIndex:(int)zIndex
{
  [representedObject setZIndex:zIndex];
  [self sendResizeToServer];
}

- (void)sendResizeToServer
{
  [[representedObject setLocation:[self frame]] sendResizeToServer];
}

@end
