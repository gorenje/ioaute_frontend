/*
 * The store of all drag and drop data. This allows the source to deposit the drag
 * data and the destination can retrieve the data from here. This makes life easier
 * for all concerned ... including the poor hacker that wrote this shieet ;)
 */
@import <Foundation/CPObject.j>

var DragDropManagerInstance = nil;

@implementation DragDropManager : CPObject
{
  CPDictionary _store;
}

- (id)init
{
  self = [super init];
  if (self) {
    _store = [[CPDictionary alloc] init];
    [_store setObject:[[CPDictionary alloc] init] forKey:TweetDragType];
    [_store setObject:[[CPDictionary alloc] init] forKey:FlickrDragType];
  }
  return self;
}

//
// Singleton class, this provides the callee with the only instance of this class.
//
+ (DragDropManager) sharedInstance 
{
  if ( !DragDropManagerInstance ) {
    DragDropManagerInstance = [[DragDropManager alloc] init];
  }
  return DragDropManagerInstance;
}

//
// Instance methods.
//

/*
 * Handle Twitter
 */
- (void)moreTweets:(CPArray)data
{
  CPLogConsole( "adding tweets to store" );
  var tweetStore = [_store objectForKey:TweetDragType];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    CPLogConsole( "Storing id str: " + [data[idx] id_str]);
    [tweetStore setObject:data[idx] forKey:[data[idx] id_str]];
  }
  CPLogConsole( "done adding objects to store: " + [tweetStore allKeys]);
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
  return [[_store objectForKey:TweetDragType] objectForKey:id_str];
}

/*
 * Handle Flickr
 */
- (void)moreFlickrImages:(CPArray)data
{
  CPLogConsole( "adding images to the drag drop store" );
  var localStore = [_store objectForKey:FlickrDragType];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    CPLogConsole( "Storing id str: " + [data[idx] id_str]);
    [localStore setObject:data[idx] forKey:[data[idx] id_str]];
  }
  CPLogConsole( "done adding objects to store: " + [localStore allKeys]);
}

- (JSObject)flickrImageForId:(CPString)id_str
{
  return [[_store objectForKey:FlickrDragType] objectForKey:id_str];
}

@end
