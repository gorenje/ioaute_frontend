
@implementation DocumentViewCell : CPView
{
  CGPoint  dragLocation;
  CGPoint  editedOrigin;

  // This is a reference to the a PMDataSource object and is basically the delegate
  // for certain events (e.g. moving or resize or deletion ...)
  CPObject representedObject;
}

- (void)setRepresentedObject:(CPObject)anObject
{
  CPLogConsole( "set represented object: '" + [anObject class] + "'");
  if ( representedObject ) {
    [representedObject removeFromSuperview];
  }
  representedObject = [anObject clone];
  [representedObject generateViewForDocument:self];
}

- (void)setSelected:(BOOL)flag
{
  [[DocumentViewEditorView sharedInstance] setDocumentViewCell:self];
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

- (void)keyDown:(CPEvent)anEvent
{
  CPLogConsole( "[DOCUMENT VIEW CELL] Key dwon: " + [anEvent keyCode]);
}

- (void)sendResizeToServer
{
  var origin = [self frame].origin;
  var location = CGRectMake(origin.x, origin.y, CGRectGetWidth([self frame]),
                            CGRectGetHeight([self frame]));
  [[CommunicationManager sharedInstance] resizeElement:[representedObject setLocation:location]];
}

@end
