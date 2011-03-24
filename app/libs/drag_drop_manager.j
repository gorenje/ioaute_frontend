/*
 * Created by Gerrit Riessen
 * Copyright 2010-2011, Gerrit Riessen
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
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
    [_store setObject:[[CPDictionary alloc] init] forKey:GoogleImagesDragType];
    [_store setObject:[[CPDictionary alloc] init] forKey:YouTubeDragType];
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
// Helper for store data into a particular CPDictionary

+ (CPArray) _addDataToStore:(CPDictionary)localStore withData:(CPArray)data
{
  for ( var idx = 0; idx < [data count]; idx++ ) {
    [localStore setObject:data[idx] forKey:[data[idx] id_str]];
  }
  return data;
}

/*
 * Handle Twitter
 */
- (void)moreTweets:(CPArray)data
{
  var tweetStore = [_store objectForKey:TweetDragType];
  [DragDropManager _addDataToStore:tweetStore withData:data];
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
    CPLogConsole("Initiating tweet request via D&D Mgr.");
    [Tweet retrieveTweetAndUpdateDragAndDrop:id_str];
  }
  return item;
}

/*
 * Handle facebook
 */
- (void)moreFacebook:(CPArray)data
{
  var localStore = [_store objectForKey:FacebookDragType];
  [DragDropManager _addDataToStore:localStore withData:data];
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
  [DragDropManager _addDataToStore:[_store objectForKey:FlickrDragType] withData:data];
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
  return [DragDropManager _addDataToStore:localStore withData:data];
}

- (ToolElement)toolElementForId:(CPString)id_str
{
  return [[_store objectForKey:ToolElementDragType] objectForKey:id_str];
}

/*
 * Handle GoogleImages
 */
- (CPArray)moreGoogleImages:(CPArray)data
{
  var localStore = [_store objectForKey:GoogleImagesDragType];
  return [DragDropManager _addDataToStore:localStore withData:data];
}

- (GoogleImage)googleImageForId:(CPString)id_str
{
  return [[_store objectForKey:GoogleImagesDragType] objectForKey:id_str];
}

/*
 * Handle YouTubeVideos
 */
- (CPArray)moreYouTubeVideos:(CPArray)data
{
  var localStore = [_store objectForKey:YouTubeDragType];
  return [DragDropManager _addDataToStore:localStore withData:data];
}

- (YouTubeVideo)youTubeVideoForId:(CPString)id_str
{
  return [[_store objectForKey:YouTubeDragType] objectForKey:id_str];
}

@end
