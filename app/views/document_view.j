
@import <Foundation/CPObject.j>

@implementation DocumentView : CPCollectionView
{
}

- (void)awakeFromCib
{
  CPLogConsole( "setting document controller as delegate" );
  [self registerForDraggedTypes:[TweetDragType]];

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
  CPLogConsole("peforming drag operations @ collection view" );
  var data = [[aSender draggingPasteboard] dataForType:TweetDragType];
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
  [self setContent:jsonObjects];
  [self setSelectionIndexes:[CPIndexSet indexSet]];
}

- (void)draggingEntered:(CPDraggingInfo)aSender
{
  CPLogConsole( "dragging entered the view" );
}

- (void)draggingExited:(CPDraggingInfo)aSender
{
  CPLogConsole( "dragging _exited_ the view" );
}

@end
