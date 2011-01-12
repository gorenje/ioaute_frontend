@implementation ToolListCell : CPBox
{
  CPTextField _label;
  CPImageView _imgView;
  CPView      _highlightView;
  ToolElement _toolObject;
}

- (void)setRepresentedObject:(ToolElement)anObject
{
  if (!_label) {
    _label = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
        
    [_label setFont:[CPFont systemFontOfSize:12.0]];
    [_label setVerticalAlignment:CPCenterVerticalTextAlignment];
    [_label setAlignment:CPLeftTextAlignment];

    _imgView = [[CPImageView alloc] initWithFrame:CGRectMakeZero()];
    [_imgView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [_imgView setImage:[anObject toolBoxImage]];
    [_imgView setImageScaling:CPScaleProportionally];
    [[_imgView image] setSize:CGSizeMake(40,40)];
    [_imgView setHasShadow:NO];
    
    [self setBorderWidth:0.5];
    [self setBorderColor:[ThemeManager borderColorToolCell]];
    [self setBorderType:CPLineBorder];
    [self setFillColor:[CPColor whiteColor]];

    [self addSubview:_imgView];
    [_label setFrameOrigin:CGPointMake(5,10)];
    [_imgView setFrameOrigin:CGPointMake(0,11)];
    [self addSubview:_label];
  }

  _toolObject = anObject;
  [_label setStringValue:[CPString stringWithFormat:"%s", [_toolObject name]]];
  [_label sizeToFit];
}

- (void)setSelected:(BOOL)flag
{
  if (!_highlightView) {
    _highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
    [_highlightView setBackgroundColor:[ThemeManager toolHighlightColor]];
  }

  if (flag) {
    [self addSubview:_highlightView positioned:CPWindowBelow relativeTo:_imgView];
  } else {
    [_highlightView removeFromSuperview];
  }
}

@end
