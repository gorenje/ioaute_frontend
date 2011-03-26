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
/*
 * This represents the green border with buttons when an page element is edited.
 * It sets up the frame and handles the callbacks when a button is clicked.
 */
var SharedDocumentViewEditorView = nil;
// how much bigger is the editor frame than the view it represents.
var ViewEditorEnlargedBy = 26;
// diameter of the handles
var ViewEditorSizeOfHandle = 16;

var CurrentShownToolTip = nil;
var ToolTipTexts = ["Delete element from page and remove from document.", 
                    "Modify properties of this element.", 
                    "Make a copy of this element and place it in the middle of the page.",
                    "Resize right", "Resize diagonal", "Resize down",
                    "Move this element.", nil];
                             
@implementation DocumentViewEditorView : CPView
{
  DocumentViewCell m_documentViewCell @accessors(property=documentViewCell,readonly);
  int              m_handleIdx;
  BOOL             m_isResizing;
  BOOL             m_isMoving;
  CPArray          m_handlesRects;
  CALayer          m_rootLayer;
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
    m_handlesRects = [];
    m_isResizing = NO;
    m_isMoving = NO;

    m_rootLayer = [CALayer layer];
    [m_rootLayer setDelegate:self];
    [self setWantsLayer:YES];
    [self setClipsToBounds:NO];
    [self setLayer:m_rootLayer];
  }
  return self;
}

// TODO accept key events.
- (void)keyDown:(CPEvent)anEvent
{
}

- (BOOL) acceptsFirstResponder 
{
  return YES;
}

- (void)setDocumentViewCell:(DocumentViewCell)aDocumentViewCell
{
  if (m_documentViewCell == aDocumentViewCell) {
    return;
  }

  [self hideToolTip];

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

    [[CPNotificationCenter defaultCenter] 
      addObserver:self
         selector:@selector(pageElementDidRotate:)
             name:PageElementDidRotateNotification
           object:[m_documentViewCell pageElement]];

    var frame  = [aDocumentViewCell frame].origin, 
      cellSize = [aDocumentViewCell bounds].size;
        
    [self setFrame:CGRectMake(frame.x - ViewEditorEnlargedBy, 
                              frame.y - ViewEditorEnlargedBy, 
                              cellSize.width + (ViewEditorEnlargedBy*2), 
                              cellSize.height + (ViewEditorEnlargedBy*2))];


    var rotation = 0;
    if ( [[m_documentViewCell pageElement] respondsToSelector:@selector(rotation)] ) {
      rotation = [[m_documentViewCell pageElement] rotationRadians];
    }
    [m_rootLayer setAffineTransform:CGAffineTransformMakeRotation(rotation)];

    // when something is being edited, it always pops to the front. Replicate this
    // permantently for the document by setting it's Z-Index to the current max plus 1.
    [m_documentViewCell setZIndex:[[DocumentViewController sharedInstance] nextZIndex]];
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

- (void)pageElementDidRotate:(CPNotification)aNotification
{
  [m_rootLayer setAffineTransform:CGAffineTransformMakeRotation([[aNotification object] 
                                                                  rotationRadians])];
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

- (void)rightMouseDown:(CPEvent)anEvent
{
  // this will ensure that right mouse does not nothing over an editor view.
  m_isMoving = YES;
  [[CPCursor closedHandCursor] set];
  [m_documentViewCell mouseDown:anEvent];
}

// - (void)rightMouseDragged:(CPEvent)anEvent
// {
//   // CPLogConsole("right mouse is being drgger");
// }

// - (void)rightMouseUp:(CPEvent)anEvent
// {
//   //  CPLogConsole("right mouse is up");
// }

/*!
  This comes from any view that choose to call this. Basically a view can
  implement the rightMouseDown method and receive the right mouse event. It
  can then pass it on to us so that i becomes editable.
*/
- (void)rightMouseDownOnView:(DocumentViewCell)aView withEvent:(CPEvent)anEvent 
{
  // this will ensure that right mouse does not nothing over an editor view.
  [self setDocumentViewCell:aView];
}

//
// Mouse actions to allow for resize and other actions on the page element.
//
- (void)mouseDown:(CPEvent)anEvent
{
  if ([anEvent clickCount] == 2 && [[m_documentViewCell pageElement] hasProperties]) {
    [[m_documentViewCell pageElement] openProperyWindow];
    return;
  }

  var location = [self convertPoint:[anEvent locationInWindow] fromView:nil];
  m_handleIdx = [self getHandleIndex:location];
  [self hideToolTip];

  switch( m_handleIdx ) {
  case 0:
    [self deletePageElement];
    break;
  case 1:
    [[m_documentViewCell pageElement] openProperyWindow];
    break;
  case 2:
    [m_documentViewCell cloneAndAddToPage];
    break;
  case 3:
  case 4:
  case 5:
    m_isResizing = YES;
    [m_documentViewCell willBeginLiveResize];
    [self setNeedsDisplay:YES];
    break;
  case 6:
    m_isMoving = YES;
    [[CPCursor closedHandCursor] set];
    [m_documentViewCell mouseDown:anEvent];
    break;
  case 7:
    [super mouseDown:anEvent];
    break;
  }
}

- (void)mouseDragged:(CPEvent)anEvent
{
  [self hideToolTip];
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

//
// Helpers
//

- (void)hideToolTip
{
  if ( CurrentShownToolTip ) {
    [CurrentShownToolTip close];
    CurrentShownToolTip = nil;
  }
}

- (void)deletePageElement
{
  [m_documentViewCell deleteFromPage];
  [self removeAllObservers];
  m_documentViewCell = nil;
  [self removeFromSuperview];
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
  // 55x55 is the minimum size for a new Size, i.e. a resize.
  return CGRectMake(new_x, new_y, MAX(new_width,55), MAX(new_height,55));
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

- (void)newButtonAtIndex:(int)idx 
                   image:(CPImage)aImage 
                    rect:(CGRect)aRect
                 context:(CGContext)aContext
{
//   m_handlesViews[idx] = [DVEVButton buttonWithImage:aImage 
//                                           withFrame:aRect
//                                          andToolTip:ToolTipTexts[idx]];
  CGContextDrawImage(aContext, aRect, aImage);
//   [self addSubview:m_handlesViews[idx]];
}

//
// Redraw
//
- (void)drawLayer:(CALayer)aLayer inContext:(CGContext)context
{
  var bounds = CGRectInset([aLayer bounds], 10.0, 10.0),
    //context = [[CPGraphicsContext currentContext] graphicsPort],
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
                        rect:rect
                     context:context];
      break;
    case 1:
      rect = CGRectMake(CGRectGetMidX(bounds)-(ViewEditorSizeOfHandle/2.0)-3.5, -2.5, 
                        ViewEditorSizeOfHandle*1.5, ViewEditorSizeOfHandle*1.5);
      if ( [[m_documentViewCell pageElement] hasProperties] ) {
        [self newButtonAtIndex:1
                         image:[[PlaceholderManager sharedInstance] propertyButton]
                          rect:rect
                       context:context];
      }
      break;
    case 2:
      rect = CGRectMake(CGRectGetMaxX(bounds)-(ViewEditorSizeOfHandle/2.0)-1, -1, 
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      [self newButtonAtIndex:2
                       image:[[PlaceholderManager sharedInstance] copyButton]
                        rect:rect
                     context:context];
      break;
    case 3:
      rect = CGRectMake(CGRectGetMaxX(bounds)-(ViewEditorSizeOfHandle/2.0)+2,
                        CGRectGetMidY(bounds)-(ViewEditorSizeOfHandle/2.0),
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      [self newButtonAtIndex:3
                       image:[[PlaceholderManager sharedInstance] resizeRightButton]
                        rect:rect
                     context:context];
      break;
    case 4:
      rect = CGRectMake( CGRectGetMaxX(bounds) - (ViewEditorSizeOfHandle/2.0) - 8,
                         CGRectGetMaxY(bounds) - (ViewEditorSizeOfHandle/2.0) - 8,
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      [self newButtonAtIndex:4
                       image:[[PlaceholderManager sharedInstance] resizeDiagonalButton]
                        rect:rect
                     context:context];
      break;
    case 5:
      rect = CGRectMake(CGRectGetMidX(bounds)-ViewEditorSizeOfHandle/2.0,
                        CGRectGetMaxY(bounds)-ViewEditorSizeOfHandle/2.0 + 2,
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      [self newButtonAtIndex:5
                       image:[[PlaceholderManager sharedInstance] resizeBottomButton]
                        rect:rect
                     context:context];
      break;
    case 6:
      rect = CGRectMake(0,
                        CGRectGetMaxY(bounds) - (ViewEditorSizeOfHandle/2.0),
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      [self newButtonAtIndex:6
                       image:[[PlaceholderManager sharedInstance] moveButton]
                        rect:rect
                     context:context];
      break;
    case 7:
      rect = CGRectMake(0,
                        CGRectGetMidY(bounds)-ViewEditorSizeOfHandle/2.0,
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      break;
    }

    m_handlesRects.push(rect);
  }
}

@end

/*!
  Represent an action on the page element.
  TODO now that there is a button, this could also propagate back an mouse clicks
  TODO to the editor view instead of it going and find (via the rectangles) the correct
  TODO action.
*/
@implementation DVEVButton : CPImageView 
{
  CPString     m_toolTip @accessors(property=toolTip);
  CPTimer      m_toolTipTimer;
  CPInvocation m_showToolTip;
}

+ (id)buttonWithImage:(CPImage)anImage 
            withFrame:(CGRect)aFrame 
           andToolTip:(CPString)aToolTip
{
  var rVal = [[DVEVButton alloc] initWithFrame:aFrame];
  [rVal setImage:anImage];
  [rVal setToolTip:aToolTip];
  return rVal;
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];
  if ( self ) {
    [self setAutoresizingMask:CPViewNotSizable];
    [self setHasShadow:NO];
    [[self window] setAcceptsMouseMovedEvents:YES];

    m_showToolTip = [[CPInvocation alloc] initWithMethodSignature:nil];
    [m_showToolTip setTarget:self];
    [m_showToolTip setSelector:@selector(showToolTip)];
    m_toolTipTimer = nil;
  }
  return self;
}

- (void)showToolTip
{
  if ( CurrentShownToolTip ) {
    [CurrentShownToolTip close];
    CurrentShownToolTip = nil;
  }
  if ( m_toolTip ) {
    CurrentShownToolTip = [TNToolTip toolTipWithString:m_toolTip
                                               forView:self
                                            closeAfter:2.5];
  }
}

- (void)mouseEntered:(CPEvent)anEvent
{
  if ( !m_toolTipTimer ) {
    m_toolTipTimer = [CPTimer scheduledTimerWithTimeInterval:2.0
                                                  invocation:m_showToolTip
                                                     repeats:NO];
  }
}

- (void)mouseExited:(CPEvent)anEvent
{
  if ( m_toolTipTimer ) [m_toolTipTimer invalidate];
  m_toolTipTimer = nil;
}

- (void)removeFromSuperview
{
  [super removeFromSuperview];
  if ( m_toolTipTimer ) [m_toolTipTimer invalidate];
  m_toolTipTimer = nil;
}

@end

