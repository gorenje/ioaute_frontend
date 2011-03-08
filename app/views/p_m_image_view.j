/*!
  Similar to CPImageView but implementing the display of images using CALayers and not 
  views. This allows to do rotation and other transformations on the image.
  
  This is heavily borrowed from ScrapBook example, part 1 ==>
     http://cappuccino.org/learn/tutorials/scrapbook-tutorial-1/
*/
@implementation PMImageView : CPImageView 
{
  CALayer m_imageLayer;
  CPImage m_image @accessors(property=image,readonly);
  float   m_rotationRadians;
  float   m_scale_x;
  float   m_scale_y;
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];
  if ( self ) {
    m_rotationRadians = 0.0;
    m_scale_x         = 1.0;
    m_scale_y         = 1.0;
    m_image           = nil;
    m_imageLayer      = [CALayer layer];
    [m_imageLayer setDelegate:self];

    [self setWantsLayer:YES];
    [self setLayer:m_imageLayer];
  }
  return self;
}

- (void)setRotationDegrees:(int)aDegreeValue
{
  [self setRotationRadians:( aDegreeValue * (Math.PI / 180) )];
}

- (void)setRotationRadians:(float)radians
{
  if (m_rotationRadians == radians) return;
        
  m_rotationRadians = radians;
  
  [m_imageLayer setAffineTransform:CGAffineTransformScale(CGAffineTransformMakeRotation(m_rotationRadians), m_scale_x, m_scale_y)];
}

- (void)setScaleWithX:(float)aScaleX withY:(float)aScaleY
{
  if ( m_scale_x == aScaleX && m_scale_y == aScaleY ) return;
  m_scale_x = aScaleX;
  m_scale_y = aScaleY;
    
  [m_imageLayer setAffineTransform:CGAffineTransformScale(CGAffineTransformMakeRotation(m_rotationRadians), m_scale_x, m_scale_y)];
}

/*!
  Set the image. Assumed is that the image is completed loaded. The status of the image
  should be checked before calling this method, e.g.:

    if ( [anImage loadStatus] == CPImageLoadStatusCompleted ) {
      [self setImage:anImage]
    }
*/
- (void)setImage:(CPImage)anImage
{
  if (m_image == anImage) return;
  m_image = anImage;
  [self setFrameOrigin:CGPointMake(0,0)];
  [self setFrameSize:CGSizeMake( [self frame].size.width, [self frame].size.height ) ];
  [m_imageLayer setNeedsDisplay];
}

- (void)drawInContext:(CGContext)aContext
{
  CGContextSetFillColor(aContext, [CPColor grayColor]);
  CGContextFillRect(aContext, [self bounds]);
}

- (void)drawLayer:(CALayer)aLayer inContext:(CGContext)aContext
{
  var bounds = [aLayer bounds];
  if ( m_image ) CGContextDrawImage(aContext, bounds, m_image);
}

@end
