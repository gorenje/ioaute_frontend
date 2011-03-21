@implementation DocumentViewCell : CPView
{
  CGPoint  dragLocation;
  CGPoint  editedOrigin;

  // This is a reference to the a PageElement object and is basically the delegate
  // for certain events (e.g. moving or resize or deletion ...)
  PageElement representedObject @accessors(property=pageElement,readonly);
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
  [self setClipsToBounds:NO];
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
}

- (void)removeNotificationListener
{
  [[CPNotificationCenter defaultCenter] 
    removeObserver:self
              name:PageElementWantsToBeDeletedNotification
            object:representedObject];
}

- (void)pageElementSuicide:(CPNotification)aNotification
{
  [self deleteFromPage];
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
}

- (void)sendResizeToServer
{
  [[representedObject setLocation:[self frame]] sendResizeToServer];
}

@end
