@import <Foundation/CPObject.j>

@implementation TweetTest : OJTestCase

- (void)testJSobjectUsage
{
  [self assertTrue:("no" == "no")];
}

- (void)testSomeBasicBooleanOperations
{
  [self assertTrue:!NO];
}

- (void)testHasPrefix
{
  [self assertTrue:[@"#fubar" hasPrefix:@"#"]];
  [self assertFalse:[@"#fubar" hasPrefix:@"@"]];
}

- (void)testSomeStringOperations
{
  var tagstring = @"#tag1 tag2 tag3";
  tagstring = [tagstring stringByReplacingOccurrencesOfString:" " withString:","];
  tagstring = [tagstring substringFromIndex:1];
  [self assert:tagstring equals:@"tag1,tag2,tag3"];
}


- (void)testSomeJsSyntax
{
  var t = 1;
  if ( t == 1 ) {
    [self assertTrue:YES];
  } else if ( t == 2 ) {
    [self assertTrue:NO];
  } else {
    [self assertTrue:NO];
  }

  t = 2;
  if ( t == 1 ) {
    [self assertTrue:NO];
  } else if ( t == 2 ) {
    [self assertTrue:YES];
  } else {
    [self assertTrue:NO];
  }

  t = 3;
  if ( t == 1 ) {
    [self assertTrue:NO];
  } else if ( t == 2 ) {
    [self assertTrue:NO];
  } else {
    [self assertTrue:YES];
  }
}

@end
