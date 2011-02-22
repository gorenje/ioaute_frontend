var SharedDocumentViewEditorView = nil;
// how much bigger is the editor frame than the view it represents.
var ViewEditorEnlargedBy = 26;
// diameter of the handles
var ViewEditorSizeOfHandle = 16;

@implementation DocumentViewEditorView : CPView
{
  DocumentViewCell m_documentViewCell;
  int              m_handleIdx;
  BOOL             m_isResizing;
  BOOL             m_isMoving;
  CPArray          m_handlesRects;
  CPArray          m_handlesViews;
}

+ (id)sharedInstance
{
  if (!SharedDocumentViewEditorView)
    SharedDocumentViewEditorView = [[DocumentViewEditorView alloc] 
                                     initWithFrame:CGRectMakeZero()];
  return SharedDocumentViewEditorView;
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];
  if (self) {
    m_handlesViews = [];
    m_handlesRects = [];
    m_isResizing = NO;
    m_isMoving = NO;
  }
  return self;
}

- (void)setDocumentViewCell:(DocumentViewCell)aDocumentViewCell
{
  if (m_documentViewCell == aDocumentViewCell) {
    return;
  }

  if (m_documentViewCell) {
    [self removeAllObservers];
  }
    
  m_documentViewCell = aDocumentViewCell;
    
  if (m_documentViewCell) {
    [[CPNotificationCenter defaultCenter] 
      addObserver:self
         selector:@selector(documentViewCellFrameChanged:)
             name:CPViewFrameDidChangeNotification
           object:m_documentViewCell];
        
    [[CPNotificationCenter defaultCenter] 
      addObserver:self
         selector:@selector(pageElementDidResize:)
             name:PageElementDidResizeNotification
           object:[m_documentViewCell pageElement]];

    var frame  = [aDocumentViewCell frame].origin, 
      cellSize = [aDocumentViewCell bounds].size;
        
    [self setFrame:CGRectMake(frame.x - ViewEditorEnlargedBy, 
                              frame.y - ViewEditorEnlargedBy, 
                              cellSize.width + (ViewEditorEnlargedBy*2), 
                              cellSize.height + (ViewEditorEnlargedBy*2))];

    [[m_documentViewCell superview] addSubview:self];
    [[m_documentViewCell superview] addSubview:m_documentViewCell];
  } else {
    [self removeFromSuperview];
  }
}

- (void)removeAllObservers
{
  [[CPNotificationCenter defaultCenter] 
    removeObserver:self
              name:PageElementDidResizeNotification
            object:[m_documentViewCell pageElement]];
  [[CPNotificationCenter defaultCenter] 
    removeObserver:self
              name:CPViewFrameDidChangeNotification
            object:m_documentViewCell];
}

- (DocumentViewCell)documentViewCell
{
  return m_documentViewCell;
}

- (void)pageElementDidResize:(CPNotification)aNotification
{
  var cellSize = [[m_documentViewCell pageElement] getSize];
  [m_documentViewCell setFrameSize:cellSize];
  [self setFrameSize:CGSizeMake(cellSize.width+(ViewEditorEnlargedBy*2), 
                                cellSize.height+(ViewEditorEnlargedBy*2))];
}

- (void)documentViewCellFrameChanged:(CPNotification)aNotification
{
  var frame = [m_documentViewCell frame],
    length = CGRectGetWidth([self frame]);

  [self setFrameOrigin:CGPointMake(CGRectGetMidX(frame) - length / 2, 
                                   CGRectGetMidY(frame) - length / 2)];
}

//
// Mouse actions to allow for resize and other actions on the page element.
//
- (void)mouseDown:(CPEvent)anEvent
{
  var location = [self convertPoint:[anEvent locationInWindow] fromView:nil];
  m_handleIdx = [self getHandleIndex:location]
  CPLogConsole("[DVE] handle is: " + m_handleIdx);
  
  if ( m_handleIdx == 0 ) {
    [m_documentViewCell deleteFromPage];
    [self removeAllObservers];
    m_documentViewCell = nil;
    [self removeFromSuperview];
  } else if ( m_handleIdx == 1 ) {
    [[m_documentViewCell pageElement] openProperyWindow];
  } else if ( m_handleIdx == 2 ) {
    [m_documentViewCell cloneAndAddToPage:location];
  } else if ( m_handleIdx == 6 ) {
    m_isMoving = YES;
    [m_documentViewCell mouseDown:anEvent];
    [[CPCursor closedHandCursor] set];
  } else if ( m_handleIdx > 0 ) {
    m_isResizing = YES;
    [m_documentViewCell willBeginLiveResize];
    [self setNeedsDisplay:YES];
  } else {
    [super mouseDown:anEvent];
  }
}

- (void)mouseDragged:(CPEvent)anEvent
{
  if ( !m_isResizing && !m_isMoving ) return;
  
  if ( m_isMoving ) {
    [m_documentViewCell mouseDragged:anEvent];
  }

  if ( m_isResizing ) {
    [[CPCursor closedHandCursor] set];

    var location = [self convertPoint:[anEvent locationInWindow] fromView:nil];
    var rect = [self makeNewSize:location];

    [m_documentViewCell 
      doResize:CGRectInset(rect, ViewEditorEnlargedBy, ViewEditorEnlargedBy)];
    [self setFrameSize:rect.size];
    [self setFrameOrigin:rect.origin];
    [self setNeedsDisplay:YES];
  }
}

- (void)mouseUp:(CPEvent)anEvent
{
  if (!m_isResizing && !m_isMoving) return;

  if ( m_isMoving ) {
    [m_documentViewCell mouseUp:anEvent];
  }
  if ( m_isResizing ) {
    [m_documentViewCell didEndLiveResize];
  }

  m_isMoving = NO;
  m_isResizing = NO;
  [[CPCursor arrowCursor] set];
}

- (CGRect)makeNewSize:(CGPoint)location
{
  var frame = [self frame];
  var new_x = frame.origin.x, new_y = frame.origin.y,
    new_width = frame.size.width, new_height = frame.size.height;
  var rect = nil;
  
  switch ( m_handleIdx ) {
  case 3:
    [[CPCursor resizeRightCursor] set];
    new_width = location.x;
    break;
  case 4:
    [[CPCursor arrowCursor] set];
    new_height = location.y;
    new_width  = location.x;
    break;
  case 5:
    [[CPCursor resizeDownCursor] set];
    new_height = location.y;
    break;
  }

  return CGRectMake(new_x, new_y, new_width, new_height);
}

- (void)newButtonAtIndex:(int)idx image:(CPImage)aImage rect:(CGRect)aRect
{
  if ( m_handlesViews[idx] ) [m_handlesViews[idx] removeFromSuperview];
  m_handlesViews[idx] = [[CPImageView alloc] initWithFrame:aRect];
  [m_handlesViews[idx] setAutoresizingMask:CPViewNotSizable];
  [m_handlesViews[idx] setHasShadow:NO];
  [m_handlesViews[idx] setImage:aImage];
  [self addSubview:m_handlesViews[idx]];
}

- (int)getHandleIndex:(CGPoint)location 
{
  for ( var idx = 0; idx < m_handlesRects.length; idx++ ) {
    if ( CGRectContainsPoint( m_handlesRects[idx], location ) ) {
      return idx;
    }
  }
  return -1;
}


//
// Redraw
//
- (void)drawRect:(CGRect)aRect
{
  var bounds = CGRectInset([self bounds], 10.0, 10.0),
    context = [[CPGraphicsContext currentContext] graphicsPort],
    radius = CGRectGetWidth(bounds) / 2.0;
    
  CGContextSetStrokeColor(context, [ThemeManager editorBgColor]);
  CGContextSetLineWidth(context, 1);
  CGContextStrokeRect(context, bounds);

  CGContextSetAlpha(context, 1.0);
  [self drawAndStoreHandles:bounds withContext:context];
}

- (void)drawAndStoreHandles:(CGRect)bounds withContext:(CGContext)context
{
  m_handlesRects = [];
  // TODO add caching for the point generation -- the bounds don't change generally (only
  // TODO on resize) so it might be possible to cache these points ...

  // handle index is defined starting at top-left and going clockwise around the frame. 
  // E.g. idx == 2 is top-right-hand corner, idx == 4 is bottom-right-hand corner.
  for ( var idx = 0; idx < 8; idx++ ) {
    var rect = nil;

    switch(idx) {
    case 0:
      rect = CGRectMake(-1.5, -1.5, ViewEditorSizeOfHandle*1.3, 
                        ViewEditorSizeOfHandle*1.3);
      [self newButtonAtIndex:0
                       image:[[PlaceholderManager sharedInstance] deleteButton]
                        rect:rect];
      break;
    case 1:
      rect = CGRectMake(CGRectGetMidX(bounds)-(ViewEditorSizeOfHandle/2.0)-3.5, -2.5, 
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      if ( [[m_documentViewCell pageElement] hasProperties] ) {
        [self newButtonAtIndex:1
                         image:[[PlaceholderManager sharedInstance] propertyButton]
                          rect:rect];
      }
      break;
    case 2:
      rect = CGRectMake(CGRectGetMaxX(bounds)-(ViewEditorSizeOfHandle/2.0)-1, -1, 
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      [self newButtonAtIndex:2
                       image:[[PlaceholderManager sharedInstance] copyButton]
                        rect:rect];
      break;
    case 3:
      rect = CGRectMake(CGRectGetMaxX(bounds)-(ViewEditorSizeOfHandle/2.0)+2,
                        CGRectGetMidY(bounds)-(ViewEditorSizeOfHandle/2.0),
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      [self newButtonAtIndex:3
                       image:[[PlaceholderManager sharedInstance] resizeRightButton]
                        rect:rect];
      break;
    case 4:
      rect = CGRectMake( CGRectGetMaxX(bounds) - (ViewEditorSizeOfHandle/2.0) - 8,
                         CGRectGetMaxY(bounds) - (ViewEditorSizeOfHandle/2.0) - 8,
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      [self newButtonAtIndex:4
                       image:[[PlaceholderManager sharedInstance] resizeDiagonalButton]
                        rect:rect];
      break;
    case 5:
      rect = CGRectMake(CGRectGetMidX(bounds)-ViewEditorSizeOfHandle/2.0,
                        CGRectGetMaxY(bounds)-ViewEditorSizeOfHandle/2.0 + 2,
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      [self newButtonAtIndex:5
                       image:[[PlaceholderManager sharedInstance] resizeBottomButton]
                        rect:rect];
      break;
    case 6:
      rect = CGRectMake(0,
                        CGRectGetMaxY(bounds) - (ViewEditorSizeOfHandle/2.0),
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      [self newButtonAtIndex:6
                       image:[[PlaceholderManager sharedInstance] moveButton]
                        rect:rect];
      break;
    case 7:
      rect = CGRectMake(0,
                        CGRectGetMidY(bounds)-ViewEditorSizeOfHandle/2.0,
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      break;
    }

    m_handlesRects.push(CGRectInset(rect, -3,-3));
  }
}

@end
