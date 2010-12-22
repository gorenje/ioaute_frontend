
@import <Foundation/CPObject.j>

@implementation DocumentView : CPCollectionView
{
}

- (void)awakeFromCib
{
  CPLogConsole( "setting document controller as delegate" );
  [self registerForDraggedTypes:[TweetDragType, FlickrDragType]];

  var documentItem = [[CPCollectionViewItem alloc] init];
  [documentItem setView:[[DocumentViewCell alloc] initWithFrame:CGRectMake(0, 0, 150, 150)]];
  [self setDelegate:self];
  [self setItemPrototype:documentItem];

  [self setMinItemSize:CGSizeMake(150, 150)];
  [self setMaxItemSize:CGSizeMake(150, 150)];
  [self setAutoresizingMask:CPViewWidthSizable];

  CPLogConsole( "Done setting document controller as delegate" );
}

// 
// The magic of drag&drop
//
- (void)performDragOperation:(CPDraggingInfo)aSender
{
  CPLogConsole("peforming drag operations @ collection view");
  var jsonObjects = [];

  var data = [[aSender draggingPasteboard] dataForType:TweetDragType];
  if ( data ) {
    CPLogConsole("[DOCUMENT VIEW] found tweet drag data");
    jsonObjects = [self dropHandleTweets:data];
  } else {
    data = [[aSender draggingPasteboard] dataForType:FlickrDragType];
    if ( data ) {
      CPLogConsole("[DOCUMENT VIEW] found flickr drag data");
      jsonObjects = [self dropHandleFlickr:data];
    }
  }

  [self setContent:jsonObjects];
  [self setSelectionIndexes:[CPIndexSet indexSet]];
  [self setHighlight:NO];
}

- (void)draggingEntered:(CPDraggingInfo)aSender
{
  [self setHighlight:YES];
}

- (void)draggingExited:(CPDraggingInfo)aSender
{
  [self setHighlight:NO];
}

/*
 * Called to highlight the document view when a drag is available or remove highligh
 * if the drag moved out of the view.
 */
- (void)setHighlight:(BOOL)flag
{
  if ( flag ) {
    [self setBackgroundColor:[CPColor redColor]];
  } else {
    [self setBackgroundColor:[CPColor whiteColor]];
  }
}

- (CPArray) dropHandleFlickr:(CPArray)data
{
  data = [CPKeyedUnarchiver unarchiveObjectWithData:data];
  var jsonObjects = [];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    var jsonObj = [[DragDropManager sharedInstance] flickrImageForId:data[idx]];
    if ( jsonObj ) {
      CPLogConsole( "Found FlickrImage : " + data[idx]);
      [jsonObjects addObject:jsonObj];
    } else {
      CPLogConsole( "FlickrImage was nil, not available for : " + data[idx]);
    }
  }
  return jsonObjects;
}

- (CPArray) dropHandleTweets:(CPArray)data
{
  data = [CPKeyedUnarchiver unarchiveObjectWithData:data];
  var jsonObjects = [];
  for ( var idx = 0; idx < [data count]; idx++ ) {
    var tweet = [[DragDropManager sharedInstance] tweetForId:data[idx]];
    if ( tweet ) {
      CPLogConsole( "Tweet text: " + tweet.text );
      [jsonObjects addObject:tweet.json];
    } else {
      CPLogConsole( "Tweet was nil, not available for : " + data[idx]);
    }
  }
  return jsonObjects;
}
@end
