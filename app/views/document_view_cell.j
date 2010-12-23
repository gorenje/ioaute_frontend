
@implementation DocumentViewCell : CPView
{
  CGPoint  dragLocation;
  CGPoint  editedOrigin;
  float    rotationRadians;
  float    editedRotationRadians;
  CPObject representedObject;
}

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

- (void)willBeginLiveRotation
{
  editedRotationRadians = rotationRadians;
}

- (void)didEndLiveRotation
{
  [self setEditedRotationRadians:rotationRadians];
}

- (void)setRotationRadians:(float)radians
{
  rotationRadians = radians;
    
  var editorView = [DocumentViewEditorView sharedInstance];
    
  if ([editorView documentViewCell] == self && [editorView rotationRadians] != radians)
    [editorView updateFromDocumentViewCell];
    
  [self setNeedsDisplay:YES];
}

- (void)setEditedRotationRadians:(float)radians
{
  if (editedRotationRadians == radians)
    return;
    
  [[[self window] undoManager] registerUndoWithTarget:self selector:@selector(setEditedRotationRadians:) object:editedRotationRadians];

  [self setRotationRadians:radians];
    
  editedRotationRadians = radians;
}

- (float)rotationRadians
{
  return rotationRadians;
}

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
    [[DocumentViewEditorView sharedInstance] setFrameOrigin:CGPointMake(origin.x + location.x - dragLocation.x, origin.y + location.y - dragLocation.y)];
  }
  dragLocation = location;
}

- (void)mouseUp:(CPEvent)anEvent
{
  [self setSelected:NO];
  // TODO store new location of the view
  [self setFrameOrigin:[self frame].origin];
  if ( self == [[DocumentViewEditorView sharedInstance] documentViewCell] ) {
    [[DocumentViewEditorView sharedInstance] setFrameOrigin:[self frame].origin];
  }
}

- (void)keyDown:(CPEvent)anEvent
{
  CPLogConsole( "Key dwon: " + [anEvent keyCode]);
}


@end
