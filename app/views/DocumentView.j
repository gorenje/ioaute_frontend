
@import <Foundation/CPObject.j>

@implementation DocumentView : CPCollectionView
{
}

- (void)awakeFromCib
{
  CPLogConsole( "setting document controller as delegate" );
  [self registerForDraggedTypes:[TweetDragType]];
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
  for ( var idx = 0; idx < [data count]; idx++ ) {
    var tweet = [[TwitterManager sharedInstance] tweetForId:data[idx]];
    if ( tweet ) {
      CPLogConsole( "Tweet text: " + tweet.text );
    } else {
      CPLogConsole( "Tweet was nil, not available for : " + data[idx]);
    }
  }
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
