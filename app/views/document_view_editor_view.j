
@import <AppKit/CPView.j>

var SharedDocumentViewEditorView = nil,
  SharedEditorHandleRadius = 5.0;

@implementation DocumentViewEditorView : CPView
{
  BOOL             isRotating;
  float            rotationRadians;
  DocumentViewCell documentViewCell;
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
        
    var frame   = [aDocumentViewCell frame],
      imageSize = [documentViewCell bounds].size,
      length    = SQRT(imageSize.width * imageSize.width + imageSize.height * imageSize.height) + 20.0;
        
    [self setFrame:CGRectMake(CGRectGetMidX(frame) - length / 2, CGRectGetMidY(frame) - length / 2, length, length)];
    
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
    
  location.x -= radius;
  location.y -= radius;
    
  var distance = SQRT(location.x * location.x + location.y * location.y);
    
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
  CGContextStrokeEllipseInRect(context, bounds);

  CGContextSetAlpha(context, 0.5);
  CGContextSetFillColor(context, [CPColor colorWithCalibratedRed:0.0 green:1.0 blue:0.0 alpha:1.0]);
  CGContextFillEllipseInRect(context, bounds);
        
  CGContextSetAlpha(context, 1.0);
  CGContextFillEllipseInRect(context, CGRectMake(CGRectGetMidX(bounds) + COS(rotationRadians) * radius - SharedEditorHandleRadius, CGRectGetMidY(bounds) + SIN(rotationRadians) * radius - SharedEditorHandleRadius, SharedEditorHandleRadius * 2.0, SharedEditorHandleRadius * 2.0));
}

@end
