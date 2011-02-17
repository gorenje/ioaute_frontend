@implementation PageNumberListCell : CPView
{
  CPTextField _label;
  CPView      _highlightView;
  CPView      _dropHighlightView;
  Page        _pageObject;
}

- (void)setRepresentedObject:(Page)anObject
{
  [self registerForDraggedTypes:[PageNumberDragType]];

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
  var label_text;
  if ( typeof( [_pageObject name] ) != "undefined" ) {
    label_text = [CPString stringWithFormat:"%d. [%s]", [_pageObject number], [_pageObject name]];
  } else {
    label_text = [CPString stringWithFormat:"%d. No Name",[_pageObject number]];
  }
  [_label setStringValue:label_text];
  [_label sizeToFit];
  [_label setFrameOrigin:CGPointMake(10,CGRectGetHeight([_label bounds]) / 2.0)];
}

//
// Drag & Drop
//
- (void)draggingEntered:(CPDraggingInfo)aSender
{
  [self setDropSelected:YES];
  [[PageViewController sharedInstance] scrollPageIntoView:[self frame]];
}

- (void)draggingExited:(CPDraggingInfo)aSender
{
  [self setDropSelected:NO];
}

// Page number dropped on me!
- (void)performDragOperation:(CPDraggingInfo)aSender
{
  [self setDropSelected:NO];
  var data = [[aSender draggingPasteboard] dataForType:PageNumberDragType];
  if ( data ) {
    var index = [CPKeyedUnarchiver unarchiveObjectWithData:data];
    [[PageViewController sharedInstance] insertPageAbove:index page:_pageObject];
  }
}

// Highlight when the mouse comes over or goes out from us on dragging.
- (void)setDropSelected:(BOOL)flag
{
  if (!_dropHighlightView) {
    _dropHighlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
    [_dropHighlightView 
      setBackgroundColor:[CPColor colorWithRed:0.9 green:0.1 blue:0.1 alpha:0.3]];
  }

  if (flag) {
    [self addSubview:_dropHighlightView positioned:CPWindowAbove relativeTo:_label];
  } else {
    [_dropHighlightView removeFromSuperview];
  }
}

// Highlight when we're the current page (or not)
- (void)setSelected:(BOOL)flag
{
  if (!_highlightView) {
    _highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
    [_highlightView setBackgroundColor:[CPColor blueColor]];
  }

  if(flag) {
    [self addSubview:_highlightView positioned:CPWindowBelow relativeTo:_label];
    [_label setBackgroundColor:[CPColor blueColor]];
    [_label setTextColor:[CPColor whiteColor]];    
    [_label setTextShadowColor:[CPColor blackColor]];
  } else {
    [_highlightView removeFromSuperview];
    [_label setBackgroundColor:[CPColor whiteColor]];
    [_label setTextColor:[CPColor blackColor]];
    [_label setTextShadowColor:[CPColor whiteColor]];
  }
}

@end
