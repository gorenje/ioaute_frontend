/*
 * AppController.j
 * CappApp
 *
 * Created by You on December 20, 2010.
 * Copyright 2010, Your Company All rights reserved.
 */

@import <Foundation/CPObject.j>
@import "Tweet.j"

@implementation RssController : CPObject
{
  NSTableView _tableView;
  NSTextField _twitterUser;
  CPArray     _tweets;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
  // This is called when the application is done loading.
}

- (void)awakeFromCib
{
  _tweets = [CPArray arrayWithObjects:nil];
}

- (CPAction) getFeed:(id)sender
{
  var userInput = [_twitterUser stringValue];
    
  if (userInput!=="") {
    var request = [CPURLRequest requestWithURL:"http://search.twitter.com/search.json?q=" + encodeURIComponent(userInput)] ;
    twitterConnection = [CPJSONPConnection connectionWithRequest:request callback:"callback" delegate:self] ;
  }
}

- (void)connection:(CPJSONPConnection)aConnection didReceiveData:(CPString)data
{
    _tweets = [Tweet initWithJSONObjects:data.results];
    [_tableView reloadData];    
}

- (void)connection:(CPJSONPConnection)aConnection didFailWithError:(CPString)error
{
    alert(error) ;
}


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
