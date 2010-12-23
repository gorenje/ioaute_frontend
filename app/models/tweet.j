@import <LPKit/LPMultiLineTextField.j>

@import <Foundation/CPObject.j>

@implementation Tweet : PMDataSource
{
  LPMultiLineTextField _label;
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

- (void) removeFromSuperview
{
  [_label removeFromSuperview];
}

- (void)generateViewForDocument:(CPView)container
{
  if (!_label) {
    _label = [[LPMultiLineTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
        
    [_label setFont:[CPFont systemFontOfSize:12.0]];
    [_label setTextShadowColor:[CPColor whiteColor]];
    // [_label setTextShadowOffset:CGSizeMake(0, 1)];
    // [_label setEditable:YES];
    [_label setScrollable:YES];
    [_label setSelectable:YES];
    //     [_label setBordered:YES];
  }

  [container addSubview:_label];
  [_label setStringValue:[self text]];
  [_label setFrameOrigin:CGPointMake(10,CGRectGetHeight([_label bounds]) / 2.0)];
}

@end
