@implementation ToolListCell : CPBox
{
  CPTextField m_label;
  CPImageView m_imgView;
  CPView      m_highlightView;
  ToolElement m_toolObject;
  TNToolTip   m_toolTip;
}

- (void)setRepresentedObject:(ToolElement)anObject
{
  if (!m_label) {
    m_label = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
        
    [m_label setFont:[CPFont systemFontOfSize:12.0]];
    [m_label setVerticalAlignment:CPCenterVerticalTextAlignment];
    [m_label setAlignment:CPLeftTextAlignment];

    m_imgView = [[CPImageView alloc] initWithFrame:CGRectMakeZero()];
    [m_imgView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [m_imgView setImage:[anObject toolBoxImage]];
    [m_imgView setImageScaling:CPScaleProportionally];
    [[m_imgView image] setSize:CGSizeMake(40,40)];
    [m_imgView setHasShadow:NO];
    
    [self setBorderWidth:0.5];
    [self setBorderColor:[ThemeManager borderColorToolCell]];
    [self setBorderType:CPLineBorder];
    [self setFillColor:[CPColor whiteColor]];

    [self addSubview:m_imgView];
    [m_label setFrameOrigin:CGPointMake(5,10)];
    [m_imgView setFrameOrigin:CGPointMake(0,11)];
    [self addSubview:m_label];
  }

  m_toolTip = nil;
  m_toolObject = anObject;
  [m_imgView setImage:[anObject toolBoxImage]];
  [m_label setStringValue:[CPString stringWithFormat:"%s", [m_toolObject name]]];
  [m_label sizeToFit];
}

- (void)setSelected:(BOOL)flag
{
  if (!m_highlightView) {
    m_highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
    [m_highlightView setBackgroundColor:[ThemeManager toolHighlightColor]];
  }

  if (flag) {
    [self addSubview:m_highlightView positioned:CPWindowBelow relativeTo:m_imgView];
    [self createToolTip];
  } else {
    [m_highlightView removeFromSuperview];
    [self removeToolTip];
  }
}

- (void)createToolTip
{
  if ( !m_toolTip && is_defined([m_toolObject toolTip]) ) {
    m_toolTip = [TNToolTip toolTipWithString:[m_toolObject toolTip] 
                                     forView:self
                                  closeAfter:2.5];
    [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(toolTipDidClose:)
                   name:CPWindowWillCloseNotification
                 object:m_toolTip];
  }
}

- (void)toolTipDidClose:(CPNotification)aNotification
{
  m_toolTip = nil;
}

- (void)removeToolTip
{
  if ( m_toolTip ) [m_toolTip close];
  m_toolTip = nil;
}

@end
