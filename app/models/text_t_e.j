@import <Foundation/CPObject.j>

@implementation TextTE : ToolElement
{

  CPString _textTyped;
}

- (void)generateViewForDocument:(CPView)container
{
  if (!_mainView) {
    _textView = [[LPMultiLineTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
    [_textView setFont:[CPFont systemFontOfSize:12.0]];
    [_textView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [_textView setTextShadowColor:[CPColor whiteColor]];

    [_textView setScrollable:YES];
    [_textView setEditable:YES];
    [_textView setSelectable:YES];
    [_textView setStringValue:@"Type Text"];

    _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
    [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [_mainView addSubview:_textView];
    
    [self setLocation:[container frame]];
    [self addToServer];
  }

  [container addSubview:_mainView];
  if ( _textTyped ) {
    [_textView setStringValue:_textTyped];
  }
}


@end

