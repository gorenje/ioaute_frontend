
TweetDragType = @"TweetDragType";

@import <Foundation/CPObject.j>
@import "app/models/Tweet.j"
@import "app/controllers/TwitterController.j"
@import "app/views/DocumentView.j"
@import "app/libs/twitter_manager.j"

@implementation AppController : CPObject
{
  CPWindow    theWindow; //this "outlet" is connected automatically by the Cib
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
    // This is called when the application is done loading.
}

- (void)awakeFromCib
{
    // This is called when the cib is done loading.
    // You can implement this method on any object instantiated from a Cib.
    // It's a useful hook for setting up current UI values, and other things. 
    
    // In this case, we want the window from Cib to become our full browser window
    [theWindow setFullBridge:YES];
}

@end
