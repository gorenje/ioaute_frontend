@import <AppKit/CPView.j>

var SharedDocumentViewEditorView = nil;
// how much bigger is the editor frame than the view it represents.
var ViewEditorEnlargedBy = 7.5;
// diameter of the handles
var ViewEditorSizeOfHandle = 10;

@implementation DocumentViewEditorView : CPView
{
  DocumentViewCell m_documentViewCell;
  int              m_handleIdx;
  BOOL             m_isResizing;
  CPArray          m_handlesRects;
}

+ (id)sharedInstance
{
  if (!SharedDocumentViewEditorView)
    SharedDocumentViewEditorView = [[DocumentViewEditorView alloc] initWithFrame:CGRectMakeZero()];
    
  return SharedDocumentViewEditorView;
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];
    
  if (self) {
    m_handlesRects = [];
    m_isResizing = NO;
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
    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(documentViewCellFrameChanged:)
                                                 name:CPViewFrameDidChangeNotification
                                               object:m_documentViewCell];
        
    [[CPNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(pageElementDidResize:)
                                                    name:PageElementDidResizeNotification
                                                  object:[m_documentViewCell pageElement]];

    var frame  = [aDocumentViewCell frame].origin, 
      cellSize = [aDocumentViewCell bounds].size;
        
    [self setFrame:CGRectMake(frame.x-ViewEditorEnlargedBy, frame.y-ViewEditorEnlargedBy, 
                              cellSize.width+(ViewEditorEnlargedBy*2), 
                              cellSize.height+(ViewEditorEnlargedBy*2))];

    [[m_documentViewCell superview] addSubview:self];
    [[m_documentViewCell superview] addSubview:m_documentViewCell];
  } else {
    [self removeFromSuperview];
  }
}

- (void)removeAllObservers
{
  [[CPNotificationCenter defaultCenter] removeObserver:self
                                                  name:PageElementDidResizeNotification
                                                object:[m_documentViewCell pageElement]];
  [[CPNotificationCenter defaultCenter] removeObserver:self
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
  CPLogConsole("[DVE] Location was x: " + location.x + " y: " + location.y );

  m_handleIdx = [self getHandleIndex:location]
  CPLogConsole("[DVE] handle is: " + m_handleIdx);

  if ( m_handleIdx == 0 ) {
    [m_documentViewCell deleteFromPage];
    [self removeAllObservers];
    m_documentViewCell = nil;
    [self removeFromSuperview];
  } else if ( m_handleIdx == 1 ) {
    [[m_documentViewCell pageElement] openProperyWindow];
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
  if ( !m_isResizing ) return;
        
  var location = [self convertPoint:[anEvent locationInWindow] fromView:nil];

  var rect = [self makeNewSize:location];

  [m_documentViewCell doResize:CGRectInset(rect, ViewEditorEnlargedBy, ViewEditorEnlargedBy)];
  [self setFrameSize:rect.size];
  [self setFrameOrigin:rect.origin];
  [self setNeedsDisplay:YES];
}

- (void)mouseUp:(CPEvent)anEvent
{
  if (!m_isResizing) return;
  m_isResizing = NO;
  [m_documentViewCell didEndLiveResize];
}

- (CGRect)makeNewSize:(CGPoint)location
{
  var frame = [self frame];
  var new_x = frame.origin.x, new_y = frame.origin.y,
    new_width = frame.size.width, new_height = frame.size.height;
  var rect = nil;
  
  switch ( m_handleIdx ) {
  case 0:
    // TODO not working, in fact is crap!
    new_x = location.x;
    new_y = location.y;
    rect = m_handlesRects[4];
    new_height = CGRectGetMidY(rect) + location.y;
    new_width = CGRectGetMidX(rect) + location.x;
    break;
  case 1:
    break;
  case 2:
    break;
  case 3:
    new_width = location.x;
    break;
  case 4:
    new_height = location.y;
    new_width  = location.x;
    break;
  case 5:
    new_height = location.y;
    break;
  case 6:
    break;
  case 7:
    break;
  }

  return CGRectMake(new_x, new_y, new_width, new_height);
}

//
// Redraw
//
- (void)drawRect:(CGRect)aRect
{
  var bounds = CGRectInset([self bounds], 5.0, 5.0),
    context = [[CPGraphicsContext currentContext] graphicsPort],
    radius = CGRectGetWidth(bounds) / 2.0;
    
  CGContextSetStrokeColor(context, [CPColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0]);
  CGContextSetLineWidth(context, 2.0);
  CGContextStrokeRect(context, bounds);

  if ( false ) { 
    // this draws a background of light green.
    CGContextSetAlpha(context, 0.5);
    CGContextSetFillColor(context, [CPColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0]);
    CGContextFillRect(context, bounds);
  }
        
  CGContextSetAlpha(context, 1.0);
  [self drawAndStoreHandles:bounds withContext:context];
}

- (CGRect)makeRectWithX:(float)xval withY:(float)yval
{
  return CGRectMake(xval, yval, ViewEditorSizeOfHandle, ViewEditorSizeOfHandle);
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
    var color = [CPColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0];
    switch(idx) {
    case 0:
      rect = [self makeRectWithX:0 withY:0];
      color = [CPColor colorWithCalibratedRed:1.0 green:0.0 blue:0.0 alpha:1.0];
      break;
    case 1:
      rect = [self makeRectWithX:CGRectGetMidX(bounds)-ViewEditorSizeOfHandle/2.0 withY:0];
      color = [CPColor colorWithCalibratedRed:0.0 green:0.0 blue:1.0 alpha:1.0];
      break;
    case 2:
      rect = [self makeRectWithX:CGRectGetMaxX(bounds)-ViewEditorSizeOfHandle/2.0 withY:0];
      break;
    case 3:
      rect = [self makeRectWithX:CGRectGetMaxX(bounds)-ViewEditorSizeOfHandle/2.0 withY:CGRectGetMidY(bounds)-ViewEditorSizeOfHandle/2.0];
      break;
    case 4:
      rect = [self makeRectWithX:CGRectGetMaxX(bounds)-ViewEditorSizeOfHandle/2.0 withY:CGRectGetMaxY(bounds)-ViewEditorSizeOfHandle/2.0];
      break;
    case 5:
      rect = [self makeRectWithX:CGRectGetMidX(bounds)-ViewEditorSizeOfHandle/2.0 withY:CGRectGetMaxY(bounds)-ViewEditorSizeOfHandle/2.0];
      break;
    case 6:
      rect = [self makeRectWithX:0 withY:CGRectGetMaxY(bounds)-ViewEditorSizeOfHandle/2.0];
      break;
    case 7:
      rect = [self makeRectWithX:0 withY:CGRectGetMidY(bounds)-ViewEditorSizeOfHandle/2.0];
      break;
    }
    // TODO because we don't support all handles, only draw the ones that are supported.
    // TODO in order to support a new handle, need to a) draw it and b) extend makeNewSize
    // TODO to support it.
    if ( idx == 0 || (idx == 1 && [[m_documentViewCell pageElement] hasProperties]) || 
         idx == 3 || idx == 4 || idx == 5 ) {
      CGContextSetFillColor(context, color);
      CGContextFillEllipseInRect(context, rect);
    }
    m_handlesRects.push(rect);
  }
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

@end
