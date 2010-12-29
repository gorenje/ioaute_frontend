/*
 * If a new drag type is added, then ensure that the DragDropManager knows about it.
 * The DD-Manager can then be used as a store for the data being dragged and dropped.
 */
TweetDragType    = @"TweetDragType";
FlickrDragType   = @"FlickrDragType";
FacebookDragType = @"FacebookDragType";

@import <Foundation/CPObject.j>
@import <AppKit/CPCookie.j>

// helpers
@import "app/helpers/application_helpers.j"
// library
@import "app/libs/drag_drop_manager.j"
@import "app/libs/placeholder_manager.j"
@import "app/libs/configuration_manager.j"
@import "app/libs/communication_workers.j"
@import "app/libs/communication_manager.j"
// models
@import "app/models/page_element.j"
@import "app/models/tweet.j"
@import "app/models/flickr.j"
@import "app/models/facebook.j"
// views
@import "app/views/document_view.j"
@import "app/views/document_view_cell.j"
@import "app/views/document_view_editor_view.j"
@import "app/views/document_resize_view.j"
@import "app/views/flickr_photo_cell.j"
@import "app/views/facebook_photo_cell.j"
@import "app/views/page_number_list_cell.j"
// controllers
@import "app/controllers/twitter_controller.j"
@import "app/controllers/flickr_controller.j"
@import "app/controllers/facebook_controller.j"

var ZoomToolbarItemIdentifier = "ZoomToolbarItemIdentifier",
  AddPageToolbarItemIdentifier = "AddPageToolbarItemIdentifier",
  FlickrWindowControlItemIdentfier = "FlickrWindowControlItemIdentfier",
  TwitterWindowControlItemIdentfier = "TwitterWindowControlItemIdentfier",
  FacebookToolbarItemIdentifier = "FacebookToolbarItemIdentifier",
  RemovePageToolbarItemIdentifier = "RemovePageToolbarItemIdentifier";

var ToolBarItems = [AddPageToolbarItemIdentifier, 
                    RemovePageToolbarItemIdentifier, 
                    FlickrWindowControlItemIdentfier,
                    TwitterWindowControlItemIdentfier,
                    FacebookToolbarItemIdentifier,
                    CPToolbarFlexibleSpaceItemIdentifier, 
                    ZoomToolbarItemIdentifier];

@implementation AppController : CPObject
{
  CPCollectionView _listPageNumbersView;
  DocumentView _documentView;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
  // install the placeholder images
  [PlaceholderManager sharedInstance];
  [[CommunicationManager sharedInstance] ping];

  var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() styleMask:CPBorderlessBridgeWindowMask],
    contentView = [theWindow contentView],
    toolbar = [[CPToolbar alloc] initWithIdentifier:"Photos"],
    bounds = [contentView bounds];

  [toolbar setDelegate:self];
  [toolbar setVisible:true];
  [theWindow setToolbar:toolbar];

  var listScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, CGRectGetHeight(bounds) - 58)];
  [listScrollView setAutohidesScrollers:YES];
  [listScrollView setAutoresizingMask:CPViewHeightSizable];

  [[listScrollView contentView] setBackgroundColor:[CPColor colorWithRed:213.0/255.0 
                                                                   green:221.0/255.0 
                                                                    blue:230.0/255.0 
                                                                   alpha:1.0]];
  var pageNumberListItem = [[CPCollectionViewItem alloc] init];
  [pageNumberListItem setView:[[PageNumberListCell alloc] initWithFrame:CGRectMakeZero()]];

  _listPageNumbersView = [[CPCollectionView alloc] initWithFrame:CGRectMake(0, 0, 200, 0)];
  [self sendOffRequestForPageNames];

  [_listPageNumbersView setDelegate:self];
  [_listPageNumbersView setItemPrototype:pageNumberListItem];
  [_listPageNumbersView setMinItemSize:CGSizeMake(20.0, 45.0)];
  [_listPageNumbersView setMaxItemSize:CGSizeMake(1000.0, 45.0)];
  [_listPageNumbersView setMaxNumberOfColumns:1];
  [_listPageNumbersView setVerticalMargin:0.0];
  [_listPageNumbersView setAutoresizingMask:CPViewWidthSizable];
  
  [listScrollView setDocumentView:_listPageNumbersView];

  [contentView addSubview:listScrollView];
  
  var pubScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(200, 0, CGRectGetWidth(bounds) - 200, CGRectGetHeight(bounds) - 58)];

  _documentView = [[DocumentView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(bounds) - 200, CGRectGetHeight(bounds) - 58)];
  [_documentView setAutoresizingMask:(CPViewWidthSizable | CPViewHeightSizable)];

  [pubScrollView setAutoresizingMask:(CPViewHeightSizable | CPViewWidthSizable)];
  [pubScrollView setDocumentView:_documentView];
  [pubScrollView setAutohidesScrollers:YES];
  [[pubScrollView contentView] setBackgroundColor:[CPColor colorWithCalibratedWhite:0.25 
                                                                           alpha:1.0]];
  [contentView addSubview:pubScrollView];
  [theWindow orderFront:self];
}

//
// Actions
//
- (void)addPage:(id)sender
{
  var string = prompt("New Page Name");

  if (string) {
    [[CommunicationManager sharedInstance] newPageForPublication:string
                                                        delegate:self 
                                                        selector:@selector(requestCompleted:)];
  }
}

- (void)removePage:(id)sender
{
}

- (void)adjustPublicationZoom:(id)sender
{
  var newSize = [sender value];
  CPLogConsole( "Adjust Zoom" );
}

- (void)collectionViewDidChangeSelection:(CPCollectionView)aCollectionView
{
  CPLogConsole( "Some one did something" );
}

- (void)showHideFlickr:(id)sender
{
  // TODO this still throughs up strange errors aber loadWindow -- pain in the ass.
  // TODO how to set the owner of the Cib file?!?
  var controller = [[FlickrWindowController alloc] initWithWindowCibPath:"Resources/FlickrWindow.cib" owner:self];
  [controller showWindow:self];
  [controller setDelegate:self];
}

- (void)showHideTwitter:(id)sender
{
  var controller = [[TwitterWindowController alloc] initWithWindowCibPath:"Resources/TwitterWindow.cib" owner:self];
  [controller showWindow:self];
  [controller setDelegate:self];
}

- (void)showHideFacebook:(id)sender
{
  var controller = [[FacebookWindowController alloc] initWithWindowCibPath:"Resources/FacebookWindow.cib" owner:self];
  [controller showWindow:self];
  [controller setDelegate:self];
}

//
// Helpers
//
- (void)sendOffRequestForPageNames
{
  [[CommunicationManager sharedInstance] pagesForPublication:self 
                                                    selector:@selector(requestCompleted:)];
}

- (void)requestCompleted:(JSObject)data 
{
  CPLogConsole( "[AppCon] got action: " + data.action );
  switch ( data.action ) {
  case "pages_index":
    if ( data.status == "ok" ) {
      [_listPageNumbersView setContent:data.data];
    }
    break;
  case "pages_new":
    if ( data.status == "ok" ) {
      [_listPageNumbersView setContent:data.data];
    }
    break;
  }
}

//
// Toolbar callbacks.
//
- (CPArray)toolbarAllowedItemIdentifiers:(CPToolbar)aToolbar
{
   return [self toolbarDefaultItemIdentifiers:aToolbar];
}

- (CPArray)toolbarDefaultItemIdentifiers:(CPToolbar)aToolbar
{
   return ToolBarItems;
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
  var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];

  switch ( anItemIdentifier ) {

  case ZoomToolbarItemIdentifier:
    [toolbarItem setView:[[DocumentResizeView alloc] initWithFrame:CGRectMake(0, 0, 180, 32)]];
    [toolbarItem setMinSize:CGSizeMake(180, 32)];
    [toolbarItem setMaxSize:CGSizeMake(180, 32)];
    [toolbarItem setLabel:"Scale"];
    break;

  case AddPageToolbarItemIdentifier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"ad"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"adh"]];
        
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(addPage:)];
    [toolbarItem setLabel:"Add Page"];

    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];

    break;

  case RemovePageToolbarItemIdentifier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"rm"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"rmh"]];

    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(removePage:)];
    [toolbarItem setLabel:"Remove Page"];
        
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case FlickrWindowControlItemIdentfier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"ad"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"adh"]];
        
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showHideFlickr:)];
    [toolbarItem setLabel:"Flickr"];

    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];

    break;

  case TwitterWindowControlItemIdentfier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"ad"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"adh"]];
        
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showHideTwitter:)];
    [toolbarItem setLabel:"Twitter"];

    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case FacebookToolbarItemIdentifier:
    [toolbarItem setLabel:@"Facebook"];
    [toolbarItem setImage:[PlaceholderManager imageFor:@"ad"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"adh"]];

    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showHideFacebook:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;
  }

  return toolbarItem;
}

@end


@implementation FacebookWindowController : CPWindowController
{
}
@end

@implementation FlickrWindowController : CPWindowController
{
}
@end

@implementation TwitterWindowController : CPWindowController
{
}
@end
