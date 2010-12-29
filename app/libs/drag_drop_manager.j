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
    [_store setObject:[[CPDictionary alloc] init] forKey:FacebookDragType];
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
// All data that is passed in is assumed to be subclasses of PageElement.
// These are then also returned.
//

/*
 * Handle Twitter
 */
- (void)moreTweets:(CPArray)data
{
  var tweetStore = [_store objectForKey:TweetDragType];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    [tweetStore setObject:data[idx] forKey:[data[idx] id_str]];
  }
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
 * Handle facebook
 */
- (void)moreFacebook:(CPArray)data
{
  CPLogConsole( "adding facebook images to the drag drop store" );
  var localStore = [_store objectForKey:FacebookDragType];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    CPLogConsole( "Storing id str: " + [data[idx] id_str]);
    [localStore setObject:data[idx] forKey:[data[idx] id_str]];
  }
  CPLogConsole( "done adding objects to store: " + [localStore allKeys]);
}
- (Facebook)facebookItemForId:(CPString)id_str
{
  return [[_store objectForKey:FacebookDragType] objectForKey:id_str];
}

/*
 * Handle Flickr
 */
- (void)moreFlickrImages:(CPArray)data
{
  var localStore = [_store objectForKey:FlickrDragType];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    [localStore setObject:data[idx] forKey:[data[idx] id_str]];
  }
}

- (Flickr)flickrImageForId:(CPString)id_str
{
  return [[_store objectForKey:FlickrDragType] objectForKey:id_str];
}

@end
