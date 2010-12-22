
/*
 * If a new drag type is added, then ensure that the DragDropManager knows about it.
 * The DD-Manager can then be used as a store for the data being dragged and dropped.
 */
TweetDragType = @"TweetDragType";
FlickrDragType = @"FlickrDragType";

@import <Foundation/CPObject.j>

@import "app/helpers/application_helpers.j"
@import "app/libs/drag_drop_manager.j"
@import "app/models/tweet.j"
@import "app/views/document_view.j"
@import "app/views/document_view_cell.j"
@import "app/views/flickr_photo_cell.j"
@import "app/views/flickr_photo_view.j"
@import "app/controllers/twitter_controller.j"
@import "app/controllers/flickr_controller.j"

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
