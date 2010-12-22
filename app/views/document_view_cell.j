@implementation DocumentViewCell : CPView
{
  CPTextField label;
  CPView      highlightView;
}

- (void)setRepresentedObject:(JSObject)anObject
{
  CPLogConsole( "set represented object" );
  if(!label)
  {
    label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
        
    [label setFont:[CPFont systemFontOfSize:16.0]];
    [label setTextShadowColor:[CPColor whiteColor]];
    [label setTextShadowOffset:CGSizeMake(0, 1)];
    [label setEditable:YES];
    [label setSelectable:YES];
    [label setBordered:YES];

    [self addSubview:label];
  }

  if ( anObject.text )
    [label setStringValue:anObject.text];
  else
    [label setStringValue:anObject.id];

  [label sizeToFit];

  [label setFrameOrigin:CGPointMake(10,CGRectGetHeight([label bounds]) / 2.0)];
}

- (void)setSelected:(BOOL)flag
{
  if(!highlightView)
  {
    highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
    [highlightView setBackgroundColor:[CPColor blueColor]];
  }

  if(flag)
  {
    [self addSubview:highlightView positioned:CPWindowBelow relativeTo:label];
    [label setTextColor:[CPColor whiteColor]];    
    [label setTextShadowColor:[CPColor blackColor]];
  }
  else
  {
    [highlightView removeFromSuperview];
    [label setTextColor:[CPColor blackColor]];
    [label setTextShadowColor:[CPColor whiteColor]];
  }
}

@end
