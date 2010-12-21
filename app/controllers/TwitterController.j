/*
 * RssController.j
 * CappApp
 *
 * Created by You on December 20, 2010.
 * Copyright 2010, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>

@implementation TwitterController : CPObject
{
  NSTableView _tableView;
  NSTextField _twitterUser;
  CPArray     _tweets;
}

- (void)awakeFromCib
{
  // This is called when the application is done loading.
  _tweets = [CPArray arrayWithObjects:nil];
  [_tableView setDelegate:self];
  [_tableView setDraggingSourceOperationMask:CPDragOperationEvery forLocal:YES];
}

// 
// The magic of drag&drop
//
- (BOOL)tableView:(CPTableView)aTableView writeRowsWithIndexes:(CPIndexSet)rowIndexes toPasteboard:(CPPasteboard)pboard
{
  CPLogConsole( "writing to paste board" );
  var data = [rowIndexes, [aTableView UID]];

  var encodedData = [CPKeyedArchiver archivedDataWithRootObject:data];
  [pboard declareTypes:[CPArray arrayWithObject:TweetDragType] owner:self];
  [pboard setData:encodedData forType:TweetDragType];

  return YES;
}

- (CPDragOperation)tableView:(CPTableView)aTableView
                   validateDrop:(id)info
                   proposedRow:(CPInteger)row
                   proposedDropOperation:(CPTableViewDropOperation)operation
{
  CPLogConsole( "validating a drop" );
  [[aTableView window] orderFront:nil];
  [aTableView setDropRow:row dropOperation:CPTableViewDropAbove];
  return CPDragOperationMove;
}

- (BOOL)tableView:(CPTableView)aTableView acceptDrop:(id)info row:(int)row dropOperation:(CPTableViewDropOperation)operation
{
  CPLogConsole( "accepting a drag" );
  return YES;
}

//
// Button action to retrieve the tweets
//
- (CPAction) getFeed:(id)sender
{
  var userInput = [_twitterUser stringValue];
    
  if (userInput!=="") {
    var request = [CPURLRequest requestWithURL:"http://search.twitter.com/search.json?q=" + encodeURIComponent(userInput)] ;
    twitterConnection = [CPJSONPConnection connectionWithRequest:request callback:"callback" delegate:self] ;
  }
}

//
// CP URL Request callbacks
//
- (void)connection:(CPJSONPConnection)aConnection didReceiveData:(CPString)data
{
    _tweets = [Tweet initWithJSONObjects:data.results];
    [_tableView reloadData];    
}

- (void)connection:(CPJSONPConnection)aConnection didFailWithError:(CPString)error
{
    alert(error) ;
}

//
// TableView protocol for setting up the table view with data
//
- (int)numberOfRowsInTableView:(CPTableView)tableView {
  return [_tweets count];
}

- (id)tableView:(CPTableView)tableView objectValueForTableColumn:(CPTableColumn)tableColumn row:(int)row
{
  if ([tableColumn identifier]===@"TwitterUserName") {
    return @"@"+[_tweets[row] fromUser];
  } else {
    return [_tweets[row] text];
  }
}
@end
