@implementation PropertyControllerRotationSupport : GRClassMixin
{
  @outlet CPSlider    m_rotationSlider;
  @outlet CPTextField m_rotationValue;
  @outlet CPView      m_rotationView;
  @outlet CPButton    m_flipButton;
}

- (void)awakeFromCibSetupRotationFields:(PageElement)aPageElement
{
  [CPBox makeBorder:m_rotationView];
  [m_rotationSlider setValue:[m_pageElement rotation]];
  [self setRotationValue:m_rotationSlider];
  [m_flipButton setState:[m_pageElement isVerticalFlipped] ? CPOnState : CPOffState];
}

- (CPAction)setRotationValue:(id)sender
{
  if ( [sender isKindOfClass:CPTextField] ) {
    [m_rotationSlider setValue:[[sender stringValue] intValue]];
  } else {
    [m_rotationValue setStringValue:(""+[sender intValue])];
  }
  [m_pageElement setRotation:[m_rotationSlider intValue]];

  if ( [m_pageElement respondsToSelector:@selector(redisplay)] ) [m_pageElement redisplay];
}

- (CPAction)setFlipState:(id)sender
{
  [m_pageElement setVerticalFlip:[sender state] == CPOnState ? 1 : 0];
}

@end
