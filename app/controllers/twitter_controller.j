@implementation TwitterController : CPWindowController
{
  @outlet CPImageView  m_spinnerImage;
  @outlet CPTableView  m_tableView;
  @outlet CPTextField  m_searchField;
  @outlet CPTextField  m_indexField;
  @outlet CPScrollView m_scrollView;

  CPArray  m_tweets;
  CPString m_nextPageUrl;
  CPTimer  m_timer;
}

- (void)awakeFromCib
{
  m_tweets = [CPArray arrayWithObjects:nil];
  [m_tableView setDelegate:self];
  [m_tableView setDraggingSourceOperationMask:CPDragOperationEvery forLocal:YES];
  [m_tableView setAllowsColumnReordering:YES];
  [m_tableView setAllowsColumnResizing:YES];
  [m_tableView setColumnAutoresizingStyle:CPTableViewLastColumnOnlyAutoresizingStyle];

  [m_spinnerImage setHidden:YES];
  [m_spinnerImage setImage:[[PlaceholderManager sharedInstance] spinner]];

  [m_searchField setTarget:self];
  [m_searchField setAction:@selector(getFeed:)];
  [m_searchField setStringValue:[[[ConfigurationManager sharedInstance] topics] anyValue]];

  [CPBox makeBorder:m_scrollView];
  // trigger the retrieval of content when the window opens.
  [self getFeed:self];
  [[CPNotificationCenter defaultCenter] addObserver:self
                                           selector:@selector(windowWillClose:)
                                               name:CPWindowWillCloseNotification
                                             object:_window];

  var scrollerObserver = [[CPInvocation alloc] initWithMethodSignature:nil];
  [scrollerObserver setTarget:self];
  [scrollerObserver setSelector:@selector(checkVerticalScroller:)];
  m_timer = [CPTimer scheduledTimerWithTimeInterval:0.5
                                         invocation:scrollerObserver
                                            repeats:YES];
  [_window makeFirstResponder:m_searchField];
}

- (void)checkVerticalScroller:(id)obj
{
  [m_indexField setStringValue:[CPString stringWithFormat:"%d of %d", 
                                         ([[m_scrollView verticalScroller] floatValue] * 
                                          [m_tweets count]),[m_tweets count]]];
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
  [[DragDropManager sharedInstance] deleteTweets:m_tweets];
  [[CPNotificationCenter defaultCenter] removeObserver:self];
  [m_timer invalidate];
}

// 
// The magic of drag&drop
//
- (BOOL)tableView:(CPTableView)aTableView writeRowsWithIndexes:(CPIndexSet)rowIndexes toPasteboard:(CPPasteboard)pboard
{
  var idx_store = [];
  [rowIndexes getIndexes:idx_store maxCount:([rowIndexes count] + 1) inIndexRange:nil];
  CPLogConsole( "Idx Store: " + idx_store );

  var data = [];
  for (var idx = 0; idx < [idx_store count]; idx++) {
    [data addObject:[m_tweets[idx_store[idx]] id_str]];
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
  var userInput = [m_searchField stringValue];
  CPLogConsole("[TwCtrl] User input was: " + userInput);

  if ( userInput && userInput !== "" ) {
    if ( [m_tweets count] > 0 ) {
      [[DragDropManager sharedInstance] deleteTweets:m_tweets];
      m_tweets = [CPArray arrayWithObjects:nil];
      m_nextPageUrl = nil;
      [m_tableView reloadData];
    }
    [m_spinnerImage setHidden:NO];
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
  m_nextPageUrl = [Tweet nextPageUrl:data.next_page];
  var more_tweets = [Tweet initWithJSONObjects:data.results];
  [[DragDropManager sharedInstance] moreTweets:more_tweets];
  [m_tweets addObjectsFromArray:more_tweets];
  [m_tableView reloadData];    
  [m_spinnerImage setHidden:YES];
}

//
// TableView protocol for setting up the table view with data
//
- (int)numberOfRowsInTableView:(CPTableView)tableView {
  // add one more row so that when this gets reached, we automagically retrieve more results.
  return ([m_tweets count] + 1);
}

- (id)tableView:(CPTableView)tableView objectValueForTableColumn:(CPTableColumn)tableColumn row:(int)row
{
  if ( m_nextPageUrl && [m_tweets count] == row ) {
    [m_spinnerImage setHidden:NO];
    [PMCMWjsonpWorker workerWithUrl:m_nextPageUrl
                           delegate:self
                           selector:@selector(updateTweetTable:)];
    m_nextPageUrl = nil;
    return "";
  } else {
    if ([tableColumn identifier]===@"TwitterUserName") {
      return [m_tweets[row] fromUser];
    } else {
      return [m_tweets[row] text];
    }
  }
}
@end
