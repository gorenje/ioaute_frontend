@implementation DocumentResizeView : CPView
{
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];
    
  var slider = [[CPSlider alloc] initWithFrame:CGRectMake(30, CGRectGetHeight(aFrame)/2.0 - 8, CGRectGetWidth(aFrame) - 65, 24)];

  [slider setMinValue:50.0];
  [slider setMaxValue:250.0];
  [slider setIntValue:150.0];
  [slider setAction:@selector(adjustPublicationZoom:)];
    
  [self addSubview:slider];
                                                             
  var label = [CPTextField flickr_labelWithText:"50"];
  [label setFrameOrigin:CGPointMake(0, CGRectGetHeight(aFrame)/2.0 - 4.0)];
  [self addSubview:label];

  label = [CPTextField flickr_labelWithText:"250"];
  [label setFrameOrigin:CGPointMake(CGRectGetWidth(aFrame) - CGRectGetWidth([label frame]), CGRectGetHeight(aFrame)/2.0 - 4.0)];
  [self addSubview:label];
    
  return self;
}

@end
