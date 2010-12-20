/*
 * DocumentController.j
 * CappApp
 *
 * Created by You on December 20, 2010.
 * Copyright 2010, Your Company All rights reserved.
 */

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
  // data[0] == <CPIndexSet 0x004081>[number of indexes: 4 (in 1 range), indexes: (2-5)]
  CPLogConsole( data[1] );
//   [_paneLayer setImage:[CPKeyedUnarchiver unarchiveObjectWithData:data]];
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
