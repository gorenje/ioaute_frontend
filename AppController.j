/*
 * If a new drag type is added, then ensure that the DragDropManager knows about it.
 * The DD-Manager can then be used as a store for the data being dragged and dropped.
 */
TweetDragType       = @"TweetDragType";
FlickrDragType      = @"FlickrDragType";
FacebookDragType    = @"FacebookDragType";
YouTubeDragType     = @"YouTubeDragType";
ToolElementDragType = @"ToolElementDragType";

var FlickrCIB = @"Resources/FlickrWindow.cib",
  FacebookCIB = @"Resources/FacebookWindow.cib",
  YouTubeCIB  = @"Resources/YouTubeWindow.cib",
  TwitterCIB  = @"Resources/TwitterWindow.cib";

/*
 * BTW mini-intro into cappuccino:
 *  var Fubar = ...; // this is a "file-wide" variable, i.e. only usable in this file.
 *  Snafu = ...; // this is a global variable, i.e. usable everywhere.
 */
@import <Foundation/CPObject.j>
@import <AppKit/CPCookie.j>
@import <LPKit/LPKit.j>

/*
 * The application_helpers.j define a number of helper methods for the AppController
 * hence we need to pre-define the class.
 */
@implementation AppController : CPObject
@end

// helpers
@import "app/helpers/application_helpers.j"
// library
@import "app/libs/drag_drop_manager.j"
@import "app/libs/placeholder_manager.j"
@import "app/libs/configuration_manager.j"
@import "app/libs/communication_workers.j"
@import "app/libs/communication_manager.j"
// models
@import "app/models/page.j"
@import "app/models/page_element.j"
@import "app/models/tweet.j"
@import "app/models/flickr.j"
@import "app/models/facebook.j"
@import "app/models/tool_element.j"
// views
@import "app/views/document_view.j"
@import "app/views/document_view_cell.j"
@import "app/views/document_view_editor_view.j"
@import "app/views/document_resize_view.j"
@import "app/views/flickr_photo_cell.j"
@import "app/views/facebook_photo_cell.j"
@import "app/views/page_number_list_cell.j"
@import "app/views/tool_list_cell.j"
// controllers
@import "app/controllers/twitter_controller.j"
@import "app/controllers/flickr_controller.j"
@import "app/controllers/you_tube_controller.j"
@import "app/controllers/facebook_controller.j"
@import "app/controllers/tool_view_controller.j"

var ZoomToolbarItemIdentifier             = "ZoomToolbarItemIdentifier",
  AddPageToolbarItemIdentifier            = "AddPageToolbarItemIdentifier",
  FlickrWindowControlItemIdentfier        = "FlickrWindowControlItemIdentfier",
  TwitterWindowControlItemIdentfier       = "TwitterWindowControlItemIdentfier",
  FacebookToolbarItemIdentifier           = "FacebookToolbarItemIdentifier",
  YouTubeToolbarItemIdentifier            = "YouTubeToolbarItemIdentifier",
  PublishPublicationToolbarItemIdentifier = "PublishPublicationToolbarItemIdentifier",
  PublishPublicationHtmlToolbarItemIdentifier = "PublishPublicationHtmlToolbarItemIdentifier",
  BitlyUrlToolbarItemIdentifier           = "BitlyUrlToolbarItemIdentifier",
  RemovePageToolbarItemIdentifier         = "RemovePageToolbarItemIdentifier";

var ToolBarItems = [CPToolbarFlexibleSpaceItemIdentifier,
                    FlickrWindowControlItemIdentfier,
                    TwitterWindowControlItemIdentfier,
                    FacebookToolbarItemIdentifier,
                    YouTubeToolbarItemIdentifier,
                    CPToolbarFlexibleSpaceItemIdentifier, 
                 // BitlyUrlToolbarItemIdentifier,
                    PublishPublicationHtmlToolbarItemIdentifier,
                    PublishPublicationToolbarItemIdentifier];
                 //ZoomToolbarItemIdentifier];

@implementation AppController (TheRest)
{
  CPCollectionView _listPageNumbersView;
  DocumentView     _documentView;
  CPTextField      _bitlyUrlLabel;
  CPToolbarItem    _bitlyToolbarItem;
  CPToolbar        _toolBar;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
  // initialise the placeholder, this then gets the images.
  [PlaceholderManager sharedInstance];
  // check the communication to the server
  [[CommunicationManager sharedInstance] ping:self 
                                     selector:@selector(publishRequestCompleted:)];

  var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() 
                                              styleMask:CPBorderlessBridgeWindowMask],
    contentView = [theWindow contentView],
    bounds = [contentView bounds];

  _toolBar = [[CPToolbar alloc] initWithIdentifier:"PubEditor"];
  [_toolBar setDelegate:self];
  [_toolBar setVisible:true];
  [theWindow setToolbar:_toolBar];

  var listScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, CGRectGetHeight(bounds) - 58)];
  [listScrollView setAutohidesScrollers:YES];
  [listScrollView setAutoresizingMask:CPViewHeightSizable];
  [[listScrollView contentView] setBackgroundColor:[CPColor colorWithRed:213.0/255.0 
                                                                   green:221.0/255.0 
                                                                    blue:230.0/255.0 
                                                                   alpha:1.0]];

  var toolsScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(0, 0, 200, CGRectGetHeight(bounds) - 58)];
  [toolsScrollView setAutohidesScrollers:YES];
  [toolsScrollView setAutoresizingMask:CPViewHeightSizable];
  [[toolsScrollView contentView] setBackgroundColor:[CPColor colorWithRed:113.0/255.0 
                                                                    green:221.0/255.0 
                                                                     blue:120.0/255.0 
                                                                    alpha:1.0]];

  _listPageNumbersView = [self createListPageNumbersView:CGRectMake(0, 0, 200, 0)];
  [self sendOffRequestForPageNames];
  [listScrollView setDocumentView:_listPageNumbersView];

  [toolsScrollView setDocumentView:[ToolViewController createToolsCollectionView:CGRectMake(0, 0, 200, 0)]];

  var splitView = [[CPSplitView alloc] initWithFrame:CGRectMake(0, 0, 200, CGRectGetHeight(bounds) - 58)];
  [splitView setVertical:NO];
  [splitView addSubview:listScrollView];
  [splitView addSubview:toolsScrollView];
  [contentView addSubview:splitView];
  
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
                                                        selector:@selector(pageRequestCompleted:)];
  }
}

- (void)removePage:(id)sender
{
  // TODO implement me.
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
  var controller = [[FlickrWindowController alloc] initWithWindowCibPath:FlickrCIB owner:self];
  [controller showWindow:self];
  [controller setDelegate:self];
}

- (void)showHideTwitter:(id)sender
{
  var controller = [[TwitterWindowController alloc] initWithWindowCibPath:TwitterCIB owner:self];
  [controller showWindow:self];
  [controller setDelegate:self];
}

- (void)showHideFacebook:(id)sender
{
  var controller = [[FacebookWindowController alloc] initWithWindowCibPath:FacebookCIB owner:self];
  [controller showWindow:self];
  [controller setDelegate:self];
}

- (void)showHideYouTube:(id)sender
{
  var controller = [[YouTubeWindowController alloc] initWithWindowCibPath:YouTubeCIB owner:self];
  [controller showWindow:self];
  [controller setDelegate:self];
}

- (void)publishPublication:(id)sender
{
  [[CommunicationManager sharedInstance] publishWithDelegate:self
                                                    selector:@selector(publishRequestCompleted:)];
}

- (void)publishPublicationHtml:(id)sender
{
  [[CommunicationManager sharedInstance] publishInHtmlWithDelegate:self
                                                          selector:@selector(publishRequestCompleted:)];
}

//
// Helpers
//
- (void)sendOffRequestForPageNames
{
  [[CommunicationManager sharedInstance] pagesForPublication:self 
                                                    selector:@selector(pageRequestCompleted:)];
}

- (void)pageRequestCompleted:(JSObject)data 
{
  CPLogConsole( "[AppCon] [Page] got action: " + data.action );
  switch ( data.action ) {
  case "pages_index":
    if ( data.status == "ok" ) {
      [_listPageNumbersView setContent:[Page initWithJSONObjects:data.data]];
    }
    break;
  case "pages_new":
    if ( data.status == "ok" ) {
      [_listPageNumbersView setContent:[Page initWithJSONObjects:data.data]];
    }
    break;
  }
}

- (void)publishRequestCompleted:(JSObject)data
{
  CPLogConsole( "[AppCon] [Publish] got action: " + data.action );
  switch ( data.action ) {
  case "publications_publish":
    if ( data.status == "ok" ) {
//       [_bitlyUrlLabel setStringValue:data.data.bitly.short_url];
//       [_bitlyUrlLabel sizeToFit];
//       [_toolBar toolbarItemDidChange:_bitlyToolbarItem];
      window.open(data.data.bitly.short_url, data.data.bitly.hash,'');
    }
    break;
  case "publications_ping":
    if ( data.status == "ok" ) {
      CPLogConsole( "Ping was ok!" );
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

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar 
   itemForItemIdentifier:(CPString)anItemIdentifier 
willBeInsertedIntoToolbar:(BOOL)aFlag
{
  var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];

  switch ( anItemIdentifier ) {

  case BitlyUrlToolbarItemIdentifier:
    _bitlyUrlLabel = [self createBitlyInfoBox:CGRectMake(0, 0, 0, 32)];
    _bitlyToolbarItem = toolbarItem;
    [toolbarItem setView:_bitlyUrlLabel];
    [toolbarItem setMinSize:CGSizeMake(120, 32)];
    [toolbarItem setMaxSize:CGSizeMake(120, 32)];
    [toolbarItem setLabel:nil];
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(redirectToBitly:)];
    break;
    
  case ZoomToolbarItemIdentifier:
    [toolbarItem setView:[[DocumentResizeView alloc] initWithFrame:CGRectMake(0, 0, 180, 32)]];
    [toolbarItem setMinSize:CGSizeMake(180, 32)];
    [toolbarItem setMaxSize:CGSizeMake(180, 32)];
    [toolbarItem setLabel:"Scale"];
    break;

  case AddPageToolbarItemIdentifier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"add"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"addHigh"]];
        
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(addPage:)];
    [toolbarItem setLabel:"Add Page"];

    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];

    break;

  case RemovePageToolbarItemIdentifier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"remove"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"removeHigh"]];

    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(removePage:)];
    [toolbarItem setLabel:"Remove Page"];
        
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case FlickrWindowControlItemIdentfier:
    [toolbarItem setImage:[PlaceholderManager imageFor:'flickr']];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:'flickrHigh']];
        
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showHideFlickr:)];

    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case TwitterWindowControlItemIdentfier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"twitter"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"twitterHigh"]];
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showHideTwitter:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case FacebookToolbarItemIdentifier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"facebook"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"facebookHigh"]];
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showHideFacebook:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case YouTubeToolbarItemIdentifier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"youtube"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"youtubeHigh"]];
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showHideYouTube:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case PublishPublicationToolbarItemIdentifier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"pdf"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"pdfHigh"]];

    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(publishPublication:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case PublishPublicationHtmlToolbarItemIdentifier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"html"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"htmlHigh"]];

    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(publishPublicationHtml:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;
  }

  return toolbarItem;
}

@end


