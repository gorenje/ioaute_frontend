@implementation PropertyControllerRotationSupport : GRClassMixin
{
  @outlet CPSlider    m_rotationSlider;
  @outlet CPTextField m_rotationValue;
  @outlet CPView      m_rotationView;
}

- (void)awakeFromCibSetupRotationFields:(PageElement)aPageElement
{
  [CPBox makeBorder:m_rotationView];
  [m_rotationSlider setValue:[m_pageElement rotation]];
  [self setRotationValue:m_rotationSlider];
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

@end
