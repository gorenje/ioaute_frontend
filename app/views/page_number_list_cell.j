@implementation PageNumberListCell : CPView
{
  CPTextField _label;
  CPView      _highlightView;
  Page        _pageObject;
}

- (void)setRepresentedObject:(Page)anObject
{
  if(!_label)
  {
    _label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
    [_label setFont:[CPFont systemFontOfSize:14.0]];
    [_label setTextShadowColor:[CPColor whiteColor]];
    [_label setTextShadowOffset:CGSizeMake(0, 0)];
    [_label setBackgroundColor:[CPColor whiteColor]];
    [self addSubview:_label];
  }

  _pageObject = anObject;
  [_label setStringValue:[CPString stringWithFormat:"%s %d", [_pageObject name], 
                                   [_pageObject number]]]
  [_label sizeToFit];
  [_label setFrameOrigin:CGPointMake(10,CGRectGetHeight([_label bounds]) / 2.0)];
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
    [_label setBackgroundColor:[CPColor blueColor]];
    [_label setTextColor:[CPColor whiteColor]];    
    [_label setTextShadowColor:[CPColor blackColor]];
  }
  else
  {
    [_highlightView removeFromSuperview];
    [_label setBackgroundColor:[CPColor whiteColor]];
    [_label setTextColor:[CPColor blackColor]];
    [_label setTextShadowColor:[CPColor whiteColor]];
  }
}

@end
