@import <LPKit/LPMultiLineTextField.j>

@import <Foundation/CPObject.j>

@implementation Tweet : PMDataSource
{
  CPImage              _quoteImage;
  CPImageView          _quoteView;
  LPMultiLineTextField _textView;
  CPTextField          _refView;
}

//
// Class method for creating an array of Tweet objects from JSON
//
+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PMDataSource generateObjectsFromJson:someJSONObjects forClass:self];
}

- (CPString) id_str
{
  return _json.id_str;
}

- (CPString) fromUser
{
  return _json.from_user;
}

- (CPString) text
{
  return _json.text;
}

- (void)imageDidLoad:(CPImage)anImage
{
  [_quoteView setImage:anImage];
}

- (void)generateViewForDocument:(CPView)container
{
  if (!_mainView) {

    if ( _quoteImage ) [_quoteImage setDelegate:nil];
    _quoteImage = [[CPImage alloc] initWithContentsOfFile:"Resources/quotes.png"];
    [_quoteImage setDelegate:self];

    _quoteView = [[CPImageView alloc] initWithFrame:CGRectMake(0,0,40,40)];
    [_quoteView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [_quoteView setImageScaling:CPScaleProportionally];
    [_quoteView setHasShadow:YES];

    
    if([_quoteImage loadStatus] == CPImageLoadStatusCompleted) {
      [_quoteView setImage:image];
    } else {
      [_quoteView setImage:nil];
    }

    _textView = [[LPMultiLineTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
    [_textView setFont:[CPFont systemFontOfSize:12.0]];
    [_textView setTextShadowColor:[CPColor whiteColor]];
    [_textView setScrollable:YES];
    [_textView setSelectable:YES];

    _refView = [[CPTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
    [_refView setFont:[CPFont systemFontOfSize:10.0]];
    [_refView setTextColor:[CPColor blueColor]];
    [_refView setTextShadowColor:[CPColor whiteColor]];
    
    _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
    [_mainView addSubview:_quoteView];
    [_mainView addSubview:_textView];
    [_mainView addSubview:_refView];
    [_quoteView setFrameOrigin:CGPointMake(0,0)];
    [_refView setFrameOrigin:CGPointMake(42,10)];
    [_textView setFrameOrigin:CGPointMake(10,40)];
  }

  [container addSubview:_mainView];
  [_textView setStringValue:[self text]];
  [_refView setStringValue:[self fromUser]];
  [_mainView setFrameOrigin:CGPointMake(0,0)];
}

@end
