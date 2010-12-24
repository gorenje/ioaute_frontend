
@import <AppKit/CPView.j>

var SharedDocumentViewEditorView = nil;

@implementation DocumentViewEditorView : CPView
{
  BOOL             isRotating;
  float            rotationRadians;
  DocumentViewCell documentViewCell;

  float _sizeOfHandle = 10; // diameter of the handles
  CGRect _handleTopLeft;
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
    rotationRadians = 0;
    isRotating = NO;
  }
    
  return self;
}

- (void)keyDown:(CPEvent)anEvent
{
  CPLogConsole( "[DOCUMENT VIEW EDITOR] Key dwon: " + [anEvent keyCode]);
}

- (void)setDocumentViewCell:(DocumentViewCell)aDocumentViewCell
{
  if (documentViewCell == aDocumentViewCell)
    return;

  var defaultCenter = [CPNotificationCenter defaultCenter];

  if (documentViewCell) {
    [defaultCenter
            removeObserver:self
                      name:CPViewFrameDidChangeNotification
                    object:documentViewCell];
  }
    
  documentViewCell = aDocumentViewCell;
    
  if (documentViewCell) {
    rotationRadians = [documentViewCell rotationRadians];
        
    [defaultCenter
                addObserver:self
                   selector:@selector(documentViewCellFrameChanged:)
                       name:CPViewFrameDidChangeNotification
                     object:documentViewCell];
        
    var frame   = [aDocumentViewCell frame].origin,
      imageSize = [aDocumentViewCell bounds].size;
        
    [self setFrame:CGRectMake(frame.x-7.5, frame.y-7.5, imageSize.width+15, imageSize.height+15)];
    [[documentViewCell superview] addSubview:self];
    [[documentViewCell superview] addSubview:documentViewCell];
  } else {
    [self removeFromSuperview];
  }
}

- (DocumentViewCell)documentViewCell
{
  return documentViewCell;
}

- (float)rotationRadians
{
  return rotationRadians;
}

- (void)updateFromDocumentViewCell
{
  rotationRadians = [documentViewCell rotationRadians];
  [self setNeedsDisplay:YES];
}

- (void)documentViewCellFrameChanged:(CPView)aView
{
  var frame = [documentViewCell frame],
    length = CGRectGetWidth([self frame]);

  [self setFrameOrigin:CGPointMake(CGRectGetMidX(frame) - length / 2, CGRectGetMidY(frame) - length / 2)];
}

- (void)mouseDown:(CPEvent)anEvent
{
  var location = [self convertPoint:[anEvent locationInWindow] fromView:nil],
    radius = CGRectGetWidth([self frame]) / 2;
  CPLogConsole(" Location was x: " + location.x + " y: " + location.y );
  CPLogConsole("  Top Corner: " + CGRectContainsPoint( _handleTopLeft, location ) );

  location.x -= radius;
  location.y -= radius;
    
  var distance = SQRT(location.x * location.x + location.y * location.y);

  CPLogConsole("Distance is : " + distance);

  if ((distance < radius + 5) && (distance > radius - 9)) {
    isRotating = YES;
    
    [documentViewCell willBeginLiveRotation];
        
    rotationRadians = ATAN2(location.y, location.x);
        
    [self setNeedsDisplay:YES];
  } else {
    [super mouseDown:anEvent];
  }
}

- (void)mouseDragged:(CPEvent)anEvent
{
  if (!isRotating)
    return;
        
  var location = [self convertPoint:[anEvent locationInWindow] fromView:nil],
    radius = CGRectGetWidth([self frame]) / 2;
        
  rotationRadians = ATAN2(location.y - radius, location.x - radius);

  [documentViewCell setRotationRadians:rotationRadians];

  [self setNeedsDisplay:YES];
}

- (void)mouseUp:(CPEvent)anEvent
{
  if (!isRotating)
    return;
    
  isRotating = NO;
    
  [documentViewCell didEndLiveRotation];
}

- (void)drawRect:(CGRect)aRect
{
  var bounds = CGRectInset([self bounds], 5.0, 5.0),
    context = [[CPGraphicsContext currentContext] graphicsPort],
    radius = CGRectGetWidth(bounds) / 2.0;
    
  CGContextSetStrokeColor(context, [CPColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0]);
  CGContextSetLineWidth(context, 2.0);
  CGContextStrokeRect(context, bounds);

  CGContextSetAlpha(context, 0.5);
  CGContextSetFillColor(context, [CPColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0]);
  CGContextFillRect(context, bounds);
        
  CGContextSetAlpha(context, 1.0);
  
  var sizeOfHandle = 10; // Diameter of the handles ...

  // top row of handles
  _handleTopLeft = CGRectMake(0, 0, sizeOfHandle, sizeOfHandle);

  CGContextFillEllipseInRect(context, CGRectMake(0, 0,
                                                 sizeOfHandle, sizeOfHandle));
  CGContextFillEllipseInRect(context, CGRectMake(CGRectGetMidX(bounds)-sizeOfHandle/2.0, 0,
                                                 sizeOfHandle, sizeOfHandle));
  CGContextFillEllipseInRect(context, CGRectMake(CGRectGetMaxX(bounds)-sizeOfHandle/2.0, 0,
                                                 sizeOfHandle, sizeOfHandle));
  // bottom row of handles
  CGContextFillEllipseInRect(context, CGRectMake(0, 
                                                 CGRectGetMaxY(bounds)-sizeOfHandle/2.0,
                                                 sizeOfHandle, sizeOfHandle));
  CGContextFillEllipseInRect(context, CGRectMake(CGRectGetMidX(bounds)-sizeOfHandle/2.0, 
                                                 CGRectGetMaxY(bounds)-sizeOfHandle/2.0,
                                                 sizeOfHandle, sizeOfHandle));
  CGContextFillEllipseInRect(context, CGRectMake(CGRectGetMaxX(bounds)-sizeOfHandle/2.0, 
                                                 CGRectGetMaxY(bounds)-sizeOfHandle/2.0,
                                                 sizeOfHandle, sizeOfHandle));
  // mid row, left and right row of handles
  CGContextFillEllipseInRect(context, CGRectMake(0, 
                                                 CGRectGetMidY(bounds)-sizeOfHandle/2.0,
                                                 sizeOfHandle, sizeOfHandle));
  CGContextFillEllipseInRect(context, CGRectMake(CGRectGetMaxX(bounds)-sizeOfHandle/2.0, 
                                                 CGRectGetMidY(bounds)-sizeOfHandle/2.0,
                                                 sizeOfHandle, sizeOfHandle));
}

@end
