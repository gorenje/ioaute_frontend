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

@end
