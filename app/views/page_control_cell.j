@implementation PageControlCell : CPView
{
  CPTextField _label;
  CPButton _button;
}

- (void)setRepresentedObject:(JSObject)anObject
{
  if ( !_label && anObject.type == "label")
  {
    _label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
        
    [_label setFont:[CPFont systemFontOfSize:12.0]];
    [_label setVerticalAlignment:CPCenterVerticalTextAlignment];
    [_label setAlignment:CPLeftTextAlignment];
  }

  switch ( anObject.type ) {
  case "button":
    if ( _button ) {
      [_button removeFromSuperview];
    }
    _button = [CPButton buttonWithTitle:anObject.name];
    // [_button setImage:[PlaceholderManager imageFor:@"add"]];
    [_button setTarget:[PageViewController sharedInstance]];
    [_button setAction:anObject.selector];
    [_button setVerticalAlignment:CPCenterVerticalTextAlignment];
    [_button setAlignment:CPCenterTextAlignment];
    [_button setFrameOrigin:CGPointMake(20,CGRectGetHeight([_button bounds]) / 8)];
    if ( _label ) {
      [_label removeFromSuperview];
    }
    [self addSubview:_button];
    break;

  case "label":
    [_label setStringValue:[CPString stringWithFormat:"%s", anObject.name]];
    [_label sizeToFit];
    [_label setFrameOrigin:CGPointMake(0,CGRectGetHeight([_label bounds]) / 2.5)];
    [self addSubview:_label];
    if ( _button ) {
      [_button removeFromSuperview];
    }
    break;
  }
}

- (void)setSelected:(BOOL)flag
{
  // intentially do nothing if selected.
}

@end
