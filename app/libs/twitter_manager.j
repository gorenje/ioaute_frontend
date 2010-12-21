/*
 * This responsible for managing the tweet data that we've collected. Centralising
 * the data so that all components can access it.
 */
@import <Foundation/CPObject.j>

var TwitterManagerInstance = nil;

@implementation TwitterManager : CPObject
{
  CPDictionary _store;
}

- (id)init
{
  self = [super init];
  if (self) {
    _store = [[CPDictionary alloc] init];
  }
  return self;
}

//
// Singleton class, this provides the callee with the only instance of this class.
//
+ (TwitterManager) sharedInstance 
{
  if ( !TwitterManagerInstance ) {
    TwitterManagerInstance = [[TwitterManager alloc] init];
  }
  return TwitterManagerInstance;
}

//
// Instance methods
//
- (void)moreTweets:(CPArray)data
{
  CPLogConsole( "adding tweets to store" );
  for ( var idx = 0; idx < [data count]; idx++ ) {
    CPLogConsole( "Storing id str: " + [data[idx] id_str]);
    [_store setObject:data[idx] forKey:[data[idx] id_str]];
  }
  CPLogConsole( "done adding objects to store: " + [_store allKeys]);
}

- (Tweet)tweetForId:(CPString)id_str 
{
  CPLogConsole( "requesting tweet with id: " + id_str );
  // TODO here we can retrieve a tweet if not in the store using the Twitter API:
  //   http://api.twitter.com/1/statuses/show/<id_str>.json
  //   (the '1' is the version of the api to use)
  // Problem is the async nature of doing this, this needs to return a "marker"
  // to tell the callee to try again (or the callee can provide a callback that
  // provides it with the tweet?)
  return [_store objectForKey:id_str];
}

@end
