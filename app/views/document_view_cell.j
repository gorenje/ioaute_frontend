@import <Foundation/CPObject.j>

@implementation DocumentViewCell : CPView
{
  CGPoint  dragLocation;
  CGPoint  editedOrigin;

  // This is a reference to the a PageElement object and is basically the delegate
  // for certain events (e.g. moving or resize or deletion ...)
  PageElement representedObject;
}

/*
 * Set from DocumentView to draw a new object (object being a PageElement object).
 */
- (void)setRepresentedObject:(CPObject)anObject
{
  CPLogConsole( "set represented object: '" + [anObject class] + "'");
  if ( representedObject ) {
    [representedObject removeFromSuperview];
  }
  representedObject = anObject;
  [representedObject generateViewForDocument:self];
}

- (void)setSelected:(BOOL)flag
{
  [[DocumentViewEditorView sharedInstance] setDocumentViewCell:self];
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
  editedOrigin = [self frame].origin;
  dragLocation = [anEvent locationInWindow];
}

- (void)mouseDragged:(CPEvent)anEvent
{
  var location = [anEvent locationInWindow],
    origin = [self frame].origin;
    
  [self setFrameOrigin:CGPointMake(origin.x + location.x - dragLocation.x, origin.y + location.y - dragLocation.y)];
  if ( self == [[DocumentViewEditorView sharedInstance] documentViewCell] ) {
    var hiLightOrigin = [[DocumentViewEditorView sharedInstance] frame].origin;
    [[DocumentViewEditorView sharedInstance] setFrameOrigin:CGPointMake(hiLightOrigin.x + location.x - dragLocation.x, hiLightOrigin.y + location.y - dragLocation.y)];
  }
  dragLocation = location;
}

- (void)mouseUp:(CPEvent)anEvent
{
  [self setSelected:NO];
  [self setFrameOrigin:[self frame].origin];
  [self sendResizeToServer];
}

- (void)sendResizeToServer
{
  // we assume that setLocation of PageElement will copy the location, not a reference.
  [[CommunicationManager sharedInstance] resizeElement:[representedObject 
                                                         setLocation:[self frame]]];
}

@end
