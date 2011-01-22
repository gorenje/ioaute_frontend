@implementation TwitterController : CPWindowController
{
  @outlet CPImageView _spinnerImage;
  @outlet CPTableView _tableView;
  @outlet CPTextField _twitterUser;

  CPArray     _tweets;
  CPString    _nextPageUrl;
}

- (void)awakeFromCib
{
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
  [[CPNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(windowWillClose:)
                                               name:CPWindowWillCloseNotification
                                             object:_window];
}

// If the window is closed, then remove our tweets from the drag+drop manager and remove
// ourself from the notification center.
- (void) windowWillClose:(CPNotification)aNotification
{
  /* This should be done but the problem is that multiple windows might have
     duplicate tweets. Which means that deleting the tweet from the D&D manager
     will prevent drags from the remaining windows that contain the same tweet(s).
     Need to find a way to delete only those tweets that aren't being displayed
     in any other twitter window. ==> Solution is that the D&D Mgr triggers retrieval
     of missing tweets in the background, so no problem here.
  */
  [[DragDropManager sharedInstance] deleteTweets:_tweets];
  [[CPNotificationCenter defaultCenter] removeObserver:self];
}

// required because the twitter controller is the file owner of the Cib.
- (void) setDelegate:(id)anObject
{
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
  if ( userInput && userInput !== "" ) {
    if ( [_tweets count] > 0 ) {
      [[DragDropManager sharedInstance] deleteTweets:_tweets];
      _tweets = [CPArray arrayWithObjects:nil];
      [_tableView reloadData];
    }
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
  _nextPageUrl = [Tweet nextPageUrl:data.next_page];
  var more_tweets = [Tweet initWithJSONObjects:data.results];
  [[DragDropManager sharedInstance] moreTweets:more_tweets];
  [_tweets addObjectsFromArray:more_tweets];
  [_tableView reloadData];    
  [_spinnerImage setHidden:YES];
}

//
// TableView protocol for setting up the table view with data
//
- (int)numberOfRowsInTableView:(CPTableView)tableView {
  // add one more row so that when this gets reached, we automagically retrieve more results.
  return ([_tweets count] + 1);
}

- (id)tableView:(CPTableView)tableView objectValueForTableColumn:(CPTableColumn)tableColumn row:(int)row
{
  if ( _nextPageUrl && [_tweets count] == row ) {
    [_spinnerImage setHidden:NO];
    [PMCMWjsonpWorker workerWithUrl:_nextPageUrl
                           delegate:self
                           selector:@selector(updateTweetTable:)];
    return "";
  } else {
    if ([tableColumn identifier]===@"TwitterUserName") {
      return [_tweets[row] fromUser];
    } else {
      return [_tweets[row] text];
    }
  }
}
@end
