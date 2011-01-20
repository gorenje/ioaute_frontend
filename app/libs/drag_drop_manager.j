/*
 * The store of all drag and drop data. This allows the source to deposit the drag
 * data and the destination can retrieve the data from here. This makes life easier
 * for all concerned ... including the poor hacker that wrote this shiet ;)
 *
 * Basically this is like a bucket into which stuff is dumped as it becomes available (i.e.
 * an Ajax request from facebook returns) and pulled out again when the item is dropped onto
 * a document view (for example). This allows the facebook windows (for example) to simple
 * concentrate on getting the data and not managing the drag&drop operations that occur.
 * This is also (IMHO) the way it's meant to be, since each object that can be D&D has
 * a type that needs to be registered. Every view that accepts a drop registers which
 * drag types it accepts.
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
    // TODO refactor to use dictionaryWithObjectsAndKeys - see theme_manager.j for example.
    _store = [[CPDictionary alloc] init];
    [_store setObject:[[CPDictionary alloc] init] forKey:TweetDragType];
    [_store setObject:[[CPDictionary alloc] init] forKey:FlickrDragType];
    [_store setObject:[[CPDictionary alloc] init] forKey:FacebookDragType];
    [_store setObject:[[CPDictionary alloc] init] forKey:ToolElementDragType];
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

- (void)deleteTweets:(CPArray)data
{
  var tweetStore = [_store objectForKey:TweetDragType];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    [tweetStore removeObjectForKey:[data[idx] id_str]];
  }
}

- (Tweet)tweetForId:(CPString)id_str 
{
  CPLogConsole( "requesting tweet with id: " + id_str );
  // Here we can retrieve a tweet if not in the store using the Twitter API:
  //   http://api.twitter.com/1/statuses/show/<id_str>.json
  // Problem is the async nature of doing this, this needs to return a "marker"
  // to tell the callee to try again (or the callee can provide a callback that
  // provides it with the tweet?). What we do is to ignore the issue and let the 
  // user try again, i.e. the initial drag does not work but in the background we
  // trigger the retrieval of the tweet and if the users tries again, suddenly the
  // drag works!
  var item = [[_store objectForKey:TweetDragType] objectForKey:id_str];
  if ( !item ) {
    [Tweet retrieveTweetAndUpdateDragAndDrop:id_str];
  }
  return item;
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

/*
 * Handle ToolElements
 */
- (CPArray)moreToolElements:(CPArray)data
{
  var localStore = [_store objectForKey:ToolElementDragType];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    [localStore setObject:data[idx] forKey:[data[idx] id_str]];
  }
  return data;
}

- (ToolElement)toolElementForId:(CPString)id_str
{
  return [[_store objectForKey:ToolElementDragType] objectForKey:id_str];
}

@end
