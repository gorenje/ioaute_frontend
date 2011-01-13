@implementation TwitterController : CPWindowController
{
  @outlet CPImageView _spinnerImage;
  @outlet CPTableView _tableView;
  @outlet CPTextField _twitterUser;

  CPArray     _tweets;
}

- (void)awakeFromCib
{
  // This is called when the application is done loading.
  _tweets = [CPArray arrayWithObjects:nil];
  [_tableView setDelegate:self];
  [_tableView setDraggingSourceOperationMask:CPDragOperationEvery forLocal:YES];
  [_spinnerImage setHidden:YES];
  [_spinnerImage setImage:[[PlaceholderManager sharedInstance] spinner]];
  [_twitterUser setTarget:self];
  [_twitterUser setAction:@selector(getFeed:)];
  [_twitterUser setStringValue:[[[ConfigurationManager sharedInstance] topics] anyValue]];
  // trigger the retrieval of content when the window opens.
  [self getFeed:self];
}

// 
// The magic of drag&drop
//
- (BOOL)tableView:(CPTableView)aTableView writeRowsWithIndexes:(CPIndexSet)rowIndexes toPasteboard:(CPPasteboard)pboard
{
  CPLogConsole( "writing to paste board" );

  var idx_store = [];
  [rowIndexes getIndexes:idx_store maxCount:([rowIndexes count] + 1) inIndexRange:nil];
  CPLogConsole( "Idx Store: " + idx_store );

  var data = [];
  for (var idx = 0; idx < [idx_store count]; idx++) {
    [data addObject:[_tweets[idx_store[idx]] id_str]];
  }
  CPLogConsole( "Data: " + data );

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
  return CPDragOperationMove;
}

- (BOOL)tableView:(CPTableView)aTableView 
       acceptDrop:(id)info 
              row:(int)row 
    dropOperation:(CPTableViewDropOperation)operation
{
  return YES;
}

//
// Button action to retrieve the tweets
//
- (CPAction) getFeed:(id)sender
{
  var userInput = [_twitterUser stringValue];
    
  if ( userInput !== "" ) {
    [_spinnerImage setHidden:NO];
    [PMCMWjsonpWorker workerWithUrl:[Tweet searchUrl:userInput]
                           delegate:self 
                           selector:@selector(updateTweetTable:)];
  }
}

//
// CP URL Request callbacks
//
- (void) updateTweetTable:(JSObject)data
{
  _tweets = [Tweet initWithJSONObjects:data.results];
  [[DragDropManager sharedInstance] moreTweets:_tweets];
  [_tableView reloadData];    
  [_spinnerImage setHidden:YES];
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
