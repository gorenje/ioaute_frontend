@import <LPKit/LPMultiLineTextField.j>

@implementation DocumentViewCell : CPView
{
  // used for twitter
  LPMultiLineTextField label;

  // Used for flickr
  CPImage         image;
  CPImageView     imageView;

  // used for all drop types.
  CGPoint     dragLocation;
  CGPoint     editedOrigin;
  float       rotationRadians;
  float       editedRotationRadians;
}

- (void)setRepresentedObject:(CPObject)anObject
{
  CPLogConsole( "set represented object: '" + [anObject class] + "'");
  if ( [anObject class] == "Flickr" ) {
    [self dropHandleFlickr:anObject];
  }
  if ( [anObject class] == "Tweet" ) {
    [self dropHandleTwitter:anObject];
  }
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

- (void)drawRect:(CGRect)aRect
{
    var context = [[CPGraphicsContext currentContext] graphicsPort],
      bounds = [self bounds];
    
    // CGContextTranslateCTM(context, FLOOR(CGRectGetWidth(bounds) / 2.0), FLOOR(CGRectGetHeight(bounds) / 2.0));
    CGContextRotateCTM(context, rotationRadians);
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

/*
 * Required for flickr
 */
- (void)imageDidLoad:(CPImage)anImage
{
  [imageView setImage:anImage];
}

/*
 * Need to handle two types (currently!) of drops: Flickr Image and a Twitter Tweet ...
 */
- (void) dropHandleTwitter:(Tweet)anObject
{
  if(!label)
  {
    label = [[LPMultiLineTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
        
    [label setFont:[CPFont systemFontOfSize:12.0]];
    [label setTextShadowColor:[CPColor whiteColor]];
    // [label setTextShadowOffset:CGSizeMake(0, 1)];
    // [label setEditable:YES];
    [label setScrollable:YES];
    [label setSelectable:YES];
    //     [label setBordered:YES];
  }

  if ( imageView ) {
    [imageView removeFromSuperview];
  }
  [self addSubview:label];

  [label setStringValue:anObject.text];
  // [label sizeToFit];
  [label setFrameOrigin:CGPointMake(10,CGRectGetHeight([label bounds]) / 2.0)];
}

- (void) dropHandleFlickr:(Flickr)anObject
{
  if(!imageView)
  {
    imageView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([self bounds])];
    [imageView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [imageView setImageScaling:CPScaleProportionally];
    [imageView setHasShadow:YES];
  }

  if ( label ) {
    [label removeFromSuperview];
  }
  [self addSubview:imageView];
    
  [image setDelegate:nil];
  image = [[CPImage alloc] initWithContentsOfFile:[anObject flickrThumbUrlForPhoto]];
  [image setDelegate:self];
    
  if([image loadStatus] == CPImageLoadStatusCompleted)
    [imageView setImage:image];
  else
    [imageView setImage:nil];
}

@end
