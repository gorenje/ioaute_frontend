@implementation PageNumberListCell : CPView
{
  CPTextField _label;
  CPView      _highlightView;
  JSObject    _representedObject;
}

- (void)setRepresentedObject:(JSObject)anObject
{
  if(!_label)
  {
    _label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
        
    [_label setFont:[CPFont systemFontOfSize:12.0]];
    [_label setTextShadowColor:[CPColor whiteColor]];
    [_label setTextShadowOffset:CGSizeMake(0, 1)];

    [self addSubview:_label];
  }

  _representedObject = anObject.page;
  [_label setStringValue:_representedObject.name];
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
