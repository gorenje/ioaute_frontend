@import <Foundation/CPObject.j>
@import "../../../app/models/page_element.j"
@import "../../../app/models/tweet.j"

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

- (void) testSortingByZindexArray
{
  var jsObj1 = ['{ "z_index" : 1, "_type" : "Tweet", "_json" : { "id_str" : 1 } }' 
                 objectFromJSON];
  var jsObj2 = ['{ "z_index" : 2, "_type" : "Tweet", "_json" : { "id_str" : 2 } }' 
                 objectFromJSON];
  var jsObj3 = ['{ "z_index" : 3, "_type" : "Tweet", "_json" : { "id_str" : 3 } }' 
                 objectFromJSON];
  var tweets = [Tweet createObjectsFromServerJson:[jsObj1, jsObj2, jsObj3]];

  [self assert:[tweets[2] zIndex] equals:3];
  [self assert:[tweets[1] zIndex] equals:2];
  [self assert:[tweets[0] zIndex] equals:1];

  [tweets sortUsingSelector:@selector(compareZ:)];
  [self assert:[tweets[0] zIndex] equals:3];
  [self assert:[tweets[1] zIndex] equals:2];
  [self assert:[tweets[2] zIndex] equals:1];
}

- (void) testSortingByZindex
{
  var jsObj1 = ['{ "z_index" : 1, "_type" : "Tweet", "_json" : { "id_str" : 1 } }' 
                 objectFromJSON];
  var jsObj2 = ['{ "z_index" : 2, "_type" : "Tweet", "_json" : { "id_str" : 2 } }' 
                 objectFromJSON];

  var tweets = [Tweet createObjectsFromServerJson:[jsObj1, jsObj2]];
  [self assert:[tweets[0] compareZ:tweets[1]] equals:CPOrderedDescending];
  [self assert:[tweets[1] compareZ:tweets[0]] equals:CPOrderedAscending];

  [tweets[1] setZIndex:[tweets[0] zIndex]];
  [self assert:[tweets[0] compareZ:tweets[1]] equals:CPOrderedSame];
  [self assert:[tweets[1] compareZ:tweets[0]] equals:CPOrderedSame];

}

- (void) testZindexProperty
{
  var jsObj1 = ['{ "z_index" : 1, "_type" : "Tweet", "_json" : { "id_str" : 1 } }' 
                 objectFromJSON];
  var tweets = [Tweet createObjectsFromServerJson:[jsObj1]];
  [tweets[0] setZIndex:3];
  [self assert:[tweets[0] zIndex] equals:3];
}


- (void) testSubstringWithChars
{
  var stringObj = @"@fubar is cool and not hot";
  var range = [stringObj rangeOfString:" "];
  var substringRange = CPMakeRange( 1, range.location-1);
  [self assert:@"fubar" equals:[stringObj substringWithRange:substringRange]];
  [self assert:@"is cool and not hot" 
        equals:[stringObj substringFromIndex:range.location+1]];

  var string = @"@fubar";
  [self assert:-1 equals:[string rangeOfString:" "].location];
}


@end
