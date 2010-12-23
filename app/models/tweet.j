@import <LPKit/LPMultiLineTextField.j>

@import <Foundation/CPObject.j>

@implementation Tweet : PMDataSource
{
}

//
// Class method for creating an array of Tweet objects from JSON
//
+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  var objects = [[CPArray alloc] init];
    
  for (var idx = 0; idx < someJSONObjects.length; idx++) {
    [objects addObject:[[Tweet alloc] initWithJSONObject:someJSONObjects[idx]]] ;
  }
    
  return objects;
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

- (void)generateViewForDocument:(CPView)container
{
  if (!_mainView) {
    _mainView = [[LPMultiLineTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
        
    [_mainView setFont:[CPFont systemFontOfSize:12.0]];
    [_mainView setTextShadowColor:[CPColor whiteColor]];
    // [_mainView setTextShadowOffset:CGSizeMake(0, 1)];
    // [_mainView setEditable:YES];
    [_mainView setScrollable:YES];
    [_mainView setSelectable:YES];
    //     [_mainView setBordered:YES];
  }

  [container addSubview:_mainView];
  [_mainView setStringValue:[self text]];
  [_mainView setFrameOrigin:CGPointMake(10,CGRectGetHeight([_mainView bounds]) / 2.0)];
}

@end
