@implementation FacebookCategoryCell : CPView
{
  CPTextField _label;
  CPView      highlightView;
}

- (void)setRepresentedObject:(JSObject)anObject
{
  if ( !_label ) {
    _label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
        
    [_label setFont:[CPFont systemFontOfSize:12.0]];
    [_label setTextShadowColor:[CPColor whiteColor]];
    [_label setTextShadowOffset:CGSizeMake(0, 1)];

    [self addSubview:_label];
  }
    
  [_label setStringValue:[CPString stringWithFormat:"%s", anObject.name]];
  [_label sizeToFit];
}

- (void)setSelected:(BOOL)flag
{
  if(!highlightView)
  {
    highlightView = [[CPView alloc] initWithFrame:[self bounds]];
    [highlightView setBackgroundColor:[CPColor colorWithCalibratedWhite:0.1 alpha:0.6]];
    [highlightView setAutoresizingMask:CPViewWidthSizable|CPViewHeightSizable];
  }

  if(flag)
  {
    [highlightView setFrame:[self bounds]];
    [self addSubview:highlightView positioned:CPWindowBelow relativeTo:_label];
  }
  else
    [highlightView removeFromSuperview];
}

@end
