@implementation PageControlCell : CPView
{
  CPTextField m_label;
  CPButton m_button;
}

- (void)setRepresentedObject:(JSObject)anObject
{
  if ( !m_label && anObject.type == "label")
  {
    m_label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
        
    [m_label setFont:[CPFont systemFontOfSize:12.0]];
    [m_label setVerticalAlignment:CPCenterVerticalTextAlignment];
    [m_label setAlignment:CPLeftTextAlignment];
  }

  switch ( anObject.type ) {
  case "button":
    if ( m_button ) {
      [m_button removeFromSuperview];
    }
    m_button = [CPButton buttonWithTitle:anObject.name];
    [m_button setTarget:[PageViewController sharedInstance]];
    [m_button setAction:anObject.selector];
    [m_button setVerticalAlignment:CPCenterVerticalTextAlignment];
    [m_button setAlignment:CPCenterTextAlignment];
    [m_button setFrameOrigin:CGPointMake(10,CGRectGetHeight([m_button bounds]) / 8)];
    if ( m_label ) {
      [m_label removeFromSuperview];
    }
    [self addSubview:m_button];
    break;

  case "label":
    [m_label setStringValue:[CPString stringWithFormat:"%s", anObject.name]];
    [m_label sizeToFit];
    [m_label setFrameOrigin:CGPointMake(0,CGRectGetHeight([m_label bounds]) / 2.5)];
    [self addSubview:m_label];
    if ( m_button ) {
      [m_button removeFromSuperview];
    }
    break;
  }
}

- (void)setSelected:(BOOL)flag
{
  // intentially do nothing if selected.
}

@end
