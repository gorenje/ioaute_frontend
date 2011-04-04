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

@implementation DocumentViewEditorView : GRRotateView
{
  DocumentViewCell m_documentViewCell @accessors(property=documentViewCell,readonly);

  int     m_handleIdx;
  BOOL    m_isResizing;
  BOOL    m_isMoving;
  CPArray m_handlesRects;
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

    [[self window] setAcceptsMouseMovedEvents:YES];
  }
  return self;
}

- (void)addDocumentViewCell:(DocumentViewCell)aDocumentViewCell
{
}

- (void)setDocumentViewCell:(DocumentViewCell)aDocumentViewCell
{
  if (m_documentViewCell == aDocumentViewCell) return;

  [self hideToolTip];

  if (m_documentViewCell) [self removeAllObservers];
    
  m_documentViewCell = aDocumentViewCell;
    
  if (m_documentViewCell) {
    [self addAllObservers];

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
    [self setRotation:rotation];

    // when something is being edited, it always pops to the front. Replicate this
    // permantently for the document by setting it's Z-Index to the current max plus 1.
    [m_documentViewCell setZIndex:[[DocumentViewController sharedInstance] nextZIndex]];

    // The following has to do with being able to type text. It will have to change
    // once text can be rotated, but for now leave as is.
    if ( [[m_documentViewCell pageElement] respondsToSelector:@selector(rotation)] ) {
      [[m_documentViewCell superview] addSubview:m_documentViewCell];
      [[m_documentViewCell superview] addSubview:self];
    } else {
      [[m_documentViewCell superview] addSubview:self];
      [[m_documentViewCell superview] addSubview:m_documentViewCell];
    }
  } else {
    [self removeFromSuperview];
  }
}

/*!
  This comes from any view that choose to call this. Basically a view can
  implement the rightMouseDown method and receive the right mouse event. It
  can then pass it on to us so that i becomes editable.
*/
- (void)focusOnDocumentViewCell:(DocumentViewCell)aView
{
  // this will ensure that right mouse does not nothing over an editor view.
  [self setDocumentViewCell:aView];
}

- (void)removeAllObservers
{
  [[CPNotificationCenter defaultCenter] 
    removeObserver:self
              name:PageElementDidRotateNotification
            object:[m_documentViewCell pageElement]];
  [[CPNotificationCenter defaultCenter] 
    removeObserver:self
              name:PageElementDidResizeNotification
            object:[m_documentViewCell pageElement]];
  [[CPNotificationCenter defaultCenter] 
    removeObserver:self
              name:CPViewFrameDidChangeNotification
            object:m_documentViewCell];
}

- (void)addAllObservers
{
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
}

/*!
  Set when an page element is moved. 
  For details, see mixins/document_view_cell_snapgrid.j
*/
- (void)setFrameOrigin:(CGPoint)aPoint
{
  [super setFrameOrigin:aPoint];
}

//
// Notification Handlers
//
- (void)pageElementDidRotate:(CPNotification)aNotification
{
  [self setRotation:[[aNotification object] rotationRadians]];
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

- (void)mouseEntered:(CPEvent)anEvent
{
  [self setCursorForEvent:anEvent];
}

- (void)mouseMoved:(CPEvent)anEvent
{
  [self setCursorForEvent:anEvent];
}

- (void)mouseExited:(CPEvent)anEvent
{
  [[CPCursor arrowCursor] set];
}

- (void)mouseDown:(CPEvent)anEvent
{
  if ([anEvent clickCount] == 2 && [[m_documentViewCell pageElement] hasProperties]) {
    [[m_documentViewCell pageElement] openProperyWindow];
    return;
  }

  m_handleIdx = [self getHandleIndex:anEvent];
  [self hideToolTip];

  switch( m_handleIdx ) {
  case 0:
    return [self deletePageElement];
  case 1:
    return [[m_documentViewCell pageElement] openProperyWindow];
  case 2:
    return [m_documentViewCell cloneAndAddToPage];
  case 3:
  case 4:
  case 5:
    m_isResizing = YES;
    [m_documentViewCell willBeginLiveResize];
    return [self setNeedsDisplay:YES];
  }
  // everything else is a move.
  m_isMoving = YES;
  [[CPCursor closedHandCursor] set];
  [m_documentViewCell mouseDown:anEvent];
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
- (void)setCursorForEvent:(CPEvent)anEvent
{
  switch ( [self getHandleIndex:anEvent] ) {
  case 0:
    return [[CPCursor disappearingItemCursor] set];
  case 1:
    return [[CPCursor contextualMenuCursor] set];
  case 2:
    return [[CPCursor dragCopyCursor] set];
  case 3:
    return [[CPCursor resizeRightCursor] set];
  case 4:
    return [[CPCursor resizeSouthEastCursor] set];
  case 5:
    return [[CPCursor resizeDownCursor] set];
  }
  [[CPCursor openHandCursor] set];
}

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

/*!
  Used for resize operations to calculate the new frame size.
*/
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
    [[CPCursor resizeSouthEastCursor] set];
    new_height = location.y;
    new_width  = location.x;
    break;
  case 5:
    [[CPCursor resizeDownCursor] set];
    new_height = location.y;
    break;
  }
  // 53x53 allows a page element size of 1x1
  return CGRectMake(new_x, new_y, MAX(new_width,53), MAX(new_height,53));
}

- (int)getHandleIndex:(CPEvent)anEvent
{
  var location = [self convertPoint:[anEvent locationInWindow] fromView:nil];

  for ( var idx = 0; idx < m_handlesRects.length; idx++ ) {
    if ( CGRectContainsPoint([[self layer] convertRect:m_handlesRects[idx] toLayer:nil], 
                             location )) {
      return idx;
    }
  }
  return -1;
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
  CGContextSetLineWidth(context, 5);
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
    var image = nil;

    switch(idx) {
    case 0:
      rect = CGRectMake(-1.5, -1.5, ViewEditorSizeOfHandle*1.3, 
                        ViewEditorSizeOfHandle*1.3);
      image = [[PlaceholderManager sharedInstance] deleteButton];
      break;
    case 1:
      rect = CGRectMake(CGRectGetMidX(bounds)-(ViewEditorSizeOfHandle/2.0)-3.5, -2.5, 
                        ViewEditorSizeOfHandle*1.5, ViewEditorSizeOfHandle*1.5);
      if ( [[m_documentViewCell pageElement] hasProperties] ) {
        image = [[PlaceholderManager sharedInstance] propertyButton];
      }
      break;
    case 2:
      rect = CGRectMake(CGRectGetMaxX(bounds)-(ViewEditorSizeOfHandle/2.0)-1, -1, 
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      image = [[PlaceholderManager sharedInstance] copyButton];
      break;
    case 3:
      rect = CGRectMake(CGRectGetMaxX(bounds)-(ViewEditorSizeOfHandle/2.0)+2,
                        CGRectGetMidY(bounds)-(ViewEditorSizeOfHandle/2.0),
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      image = [[PlaceholderManager sharedInstance] resizeRightButton];
      break;
    case 4:
      rect = CGRectMake( CGRectGetMaxX(bounds) - (ViewEditorSizeOfHandle/2.0) - 8,
                         CGRectGetMaxY(bounds) - (ViewEditorSizeOfHandle/2.0) - 8,
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      image = [[PlaceholderManager sharedInstance] resizeDiagonalButton];
      break;
    case 5:
      rect = CGRectMake(CGRectGetMidX(bounds)-ViewEditorSizeOfHandle/2.0,
                        CGRectGetMaxY(bounds)-ViewEditorSizeOfHandle/2.0 + 2,
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      image = [[PlaceholderManager sharedInstance] resizeBottomButton];
      break;
    case 6:
      rect = CGRectMake(0,
                        CGRectGetMaxY(bounds) - (ViewEditorSizeOfHandle/2.0),
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      break;
    case 7:
      rect = CGRectMake(0,
                        CGRectGetMidY(bounds)-ViewEditorSizeOfHandle/2.0,
                        ViewEditorSizeOfHandle*1.3, ViewEditorSizeOfHandle*1.3);
      break;
    }

    if ( image ) CGContextDrawImage(context, rect, image);
    m_handlesRects.push(rect);
  }
}

@end

