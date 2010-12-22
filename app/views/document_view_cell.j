@implementation DocumentViewCell : CPView
{
  // used for twitter
  CPTextField label;
  // Used for flickr
  CPImage         image;
  CPImageView     imageView;

  // used for all drop types.
  CPView      highlightView;
  CGPoint     dragLocation;
  CGPoint     editedOrigin;
}

- (void)setRepresentedObject:(CPObject)anObject
{
  CPLogConsole( "set represented object: '" + [anObject class] + "'");
  if ( [anObject class] == "Flickr" ) {
    CPLogConsole( "Hm ... seems to be flickr" );
    [self dropHandleFlickr:anObject];
  }
  if ( [anObject class] == "Tweet" ) {
    CPLogConsole( "Hm ... seems to be twitter" );
    [self dropHandleTwitter:anObject];
  }
}

- (void)setSelected:(BOOL)flag
{
  if(!highlightView)
  {
    highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
    [highlightView setBackgroundColor:[CPColor blueColor]];
  }

  if(flag)
  {
    [self addSubview:highlightView positioned:CPWindowBelow relativeTo:label];
    [label setTextColor:[CPColor whiteColor]];    
    [label setTextShadowColor:[CPColor blackColor]];
  }
  else
  {
    [highlightView removeFromSuperview];
    [label setTextColor:[CPColor blackColor]];
    [label setTextShadowColor:[CPColor whiteColor]];
  }
}

- (void)mouseDown:(CPEvent)anEvent
{
  CPLogConsole( "[DOCUMENT VIEW] mouse down" );
  editedOrigin = [self frame].origin;
  dragLocation = [anEvent locationInWindow];
}

- (void)mouseDragged:(CPEvent)anEvent
{
  CPLogConsole( "[DOCUMENT VIEW] mouse dragged" );
  var location = [anEvent locationInWindow],
    origin = [self frame].origin;
    
  [self setFrameOrigin:CGPointMake(origin.x + location.x - dragLocation.x, origin.y + location.y - dragLocation.y)];

  dragLocation = location;
}

- (void)mouseUp:(CPEvent)anEvent
{
  CPLogConsole( "[DOCUMENT VIEW] mouse up" );
  // TODO store new location of the view
  [self setFrameOrigin:[self frame].origin];
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
    label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
        
    [label setFont:[CPFont systemFontOfSize:16.0]];
    [label setTextShadowColor:[CPColor whiteColor]];
    [label setTextShadowOffset:CGSizeMake(0, 1)];
    [label setEditable:YES];
    [label setSelectable:YES];
    [label setBordered:YES];
  }

  if ( imageView ) {
    [self replaceSubview:imageView with:label];
  } else {
    [self addSubview:label];
  }

  [label setStringValue:anObject.text];
  [label sizeToFit];
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
    [self replaceSubview:label with:imageView];
  } else {
    [self addSubview:imageView];
  }
    
  [image setDelegate:nil];

  image = [[CPImage alloc] initWithContentsOfFile:[anObject flickrThumbUrlForPhoto]];

  [image setDelegate:self];
    
  if([image loadStatus] == CPImageLoadStatusCompleted)
    [imageView setImage:image];
  else
    [imageView setImage:nil];
}

@end
