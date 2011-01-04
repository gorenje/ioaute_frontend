@implementation ToolListCell : CPView
{
  CPTextField _label;
  CPView      _highlightView;
  ToolElement _toolObject;
}

- (void)setRepresentedObject:(ToolElement)anObject
{
  if(!_label)
  {
    _label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
        
    [_label setFont:[CPFont systemFontOfSize:12.0]];
    [_label setVerticalAlignment:CPCenterVerticalTextAlignment];
    [_label setAlignment:CPLeftTextAlignment];
    [self addSubview:_label];
  }

  _toolObject = anObject;
  [_label setStringValue:[CPString stringWithFormat:"%s", [_toolObject name]]];
  [_label sizeToFit];
  [_label setFrameOrigin:CGPointMake(20,CGRectGetHeight([_label bounds]) / 1.5)];
}

- (void)setSelected:(BOOL)flag
{
  if(!_highlightView)
  {
    _highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
    [_highlightView setBackgroundColor:[CPColor blueColor]];
  }

  if(flag)
  {
    [self addSubview:_highlightView positioned:CPWindowBelow relativeTo:_label];
    [_label setTextColor:[CPColor whiteColor]];    
    [_label setTextShadowColor:[CPColor blackColor]];
  }
  else
  {
    [_highlightView removeFromSuperview];
    [_label setTextColor:[CPColor blackColor]];
    [_label setTextShadowColor:[CPColor whiteColor]];
  }
}

@end
