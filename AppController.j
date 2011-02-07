/*
 * If a new drag type is added, then ensure that the DragDropManager knows about it.
 * The DD-Manager can then be used as a store for the data being dragged and dropped.
 */
TweetDragType        = @"TweetDragType";
FlickrDragType       = @"FlickrDragType";
FacebookDragType     = @"FacebookDragType";
YouTubeDragType      = @"YouTubeDragType"; // TODO
ToolElementDragType  = @"ToolElementDragType";
GoogleImagesDragType = @"GoogleImagesDragType";

/*
 * Notifications
 */
PageViewPageNumberDidChangeNotification = @"PageViewPageNumberDidChangeNotification";
PageViewRetrievedPagesNotification = @"PageViewRetrievedPagesNotification";
PageViewPageWasDeletedNotification = @"PageViewPageWasDeletedNotification";
DocumentViewControllerAllPagesLoaded = @"DocumentViewControllerAllPagesLoaded";
PageViewLastPageWasDeletedNotification = @"PageViewLastPageWasDeletedNotification";
ConfigurationManagerToolBoxArrivedNotification = @"ConfigurationManagerToolBoxArrivedNotification";
PageElementDidResizeNotification = @"PageElementDidResizeNotification";

var FlickrCIB     = @"FlickrWindow",
  FacebookCIB     = @"FacebookWindow",
  YouTubeCIB      = @"YouTubeWindow",
  GoogleImagesCIB = @"GoogleImagesWindow",
  TwitterCIB      = @"TwitterWindow";

/*
 * Property Windows
 */
LinkTEPropertyWindowCIB        = @"LinkTEProperties";
HighlightTEPropertyWindowCIB   = @"HighlightTEProperties";
ImageTEPropertyWindowCIB       = @"ImageTEProperties";
TwitterFeedTEPropertyWindowCIB = @"TwitterFeedTEProperties";
TextTEPropertyWindowCIB        = @"TextTEProperties";
PagePropertyWindowCIB          = @"PageProperties";

/*
 * BTW mini-intro into cappuccino:
 *  var Fubar = ...; // this is a "file-wide" variable, i.e. only usable in this file.
 *  Snafu = ...; // this is a global variable, i.e. usable everywhere.
 */
@import <Foundation/CPObject.j>
@import <AppKit/CPCookie.j>
@import <LPKit/LPKit.j>
@import <LPKit/LPMultiLineTextField.j>

/*
 * The application_helpers.j define a number of helper methods for the AppController
 * hence we need to pre-define the class.
 */
@implementation AppController : CPObject
@end

// helpers
@import "app/helpers/application_helpers.j"
@import "app/helpers/image_loader_helpers.j"
// library
@import "app/libs/drag_drop_manager.j"
@import "app/libs/placeholder_manager.j"
@import "app/libs/configuration_manager.j"
@import "app/libs/communication_workers.j"
@import "app/libs/communication_manager.j"
@import "app/libs/theme_manager.j"
// models
@import "app/models/page.j"
@import "app/models/page_element.j"
@import "app/models/tweet.j"
@import "app/models/flickr.j"
@import "app/models/facebook.j"
@import "app/models/google_image.j"
@import "app/models/tool_element.j"
@import "app/models/image_t_e.j"
@import "app/models/text_t_e.j"
@import "app/models/fb_like_t_e.j"
@import "app/models/twitter_feed_t_e.j"
@import "app/models/digg_button_t_e.j"
@import "app/models/link_t_e.j"
@import "app/models/moustache_t_e.j"
@import "app/models/highlight_t_e.j"
@import "app/models/you_tube_video.j"
// views
@import "app/views/document_view.j"
@import "app/views/document_view_cell.j"
@import "app/views/document_view_editor_view.j"
@import "app/views/document_resize_view.j"
@import "app/views/base_image_cell.j"
@import "app/views/flickr_photo_cell.j"
@import "app/views/facebook_photo_cell.j"
@import "app/views/google_images_photo_cell.j"
@import "app/views/you_tube_photo_cell.j"
@import "app/views/facebook_category_cell.j"
@import "app/views/page_number_list_cell.j"
@import "app/views/page_control_cell.j"
@import "app/views/tool_list_cell.j"
// controllers
@import "app/controllers/twitter_controller.j"
@import "app/controllers/flickr_controller.j"
@import "app/controllers/you_tube_controller.j"
@import "app/controllers/facebook_controller.j"
@import "app/controllers/google_images_controller.j"
@import "app/controllers/tool_view_controller.j"
@import "app/controllers/page_view_controller.j"
@import "app/controllers/document_view_controller.j"
@import "app/controllers/document_view_controller_edit_existing.j"
// controllers - property windows
@import "app/controllers/properties/property_window_controller.j"
@import "app/controllers/properties/property_link_t_e_controller.j"
@import "app/controllers/properties/property_highlight_t_e_controller.j"
@import "app/controllers/properties/property_image_t_e_controller.j"
@import "app/controllers/properties/property_twitter_feed_t_e_controller.j"
@import "app/controllers/properties/property_text_t_e_controller.j"
@import "app/controllers/properties/property_text_t_e_controller.j"
@import "app/controllers/properties/property_page_controller.j"

var ZoomToolbarItemIdentifier             = "ZoomToolbarItemIdentifier",
  AddPageToolbarItemIdentifier            = "AddPageToolbarItemIdentifier",
  FlickrWindowControlItemIdentfier        = "FlickrWindowControlItemIdentfier",
  TwitterWindowControlItemIdentfier       = "TwitterWindowControlItemIdentfier",
  FacebookToolbarItemIdentifier           = "FacebookToolbarItemIdentifier",
  YouTubeToolbarItemIdentifier            = "YouTubeToolbarItemIdentifier",
  DiggToolbarItemIdentifier               = "DiggToolbarItemIdentifier",
  StumbleuponToolbarItemIdentifier        = "StumbleuponToolbarItemIdentifier",
  PublishPublicationToolbarItemIdentifier = "PublishPublicationToolbarItemIdentifier",
  PublishPublicationHtmlToolbarItemIdentifier = "PublishPublicationHtmlToolbarItemIdentifier",
  BitlyUrlToolbarItemIdentifier           = "BitlyUrlToolbarItemIdentifier",
  GoogleImagesWindowControlItemIdentifier = "GoogleImagesWindowControlItemIdentifier",
  RemovePageToolbarItemIdentifier         = "RemovePageToolbarItemIdentifier";

var ToolBarItems = [CPToolbarFlexibleSpaceItemIdentifier,
                    FlickrWindowControlItemIdentfier,
                    TwitterWindowControlItemIdentfier,
                    FacebookToolbarItemIdentifier,
                    YouTubeToolbarItemIdentifier,
                    GoogleImagesWindowControlItemIdentifier,
                    StumbleuponToolbarItemIdentifier,
                    DiggToolbarItemIdentifier,
                    CPToolbarFlexibleSpaceItemIdentifier, 
                    PublishPublicationHtmlToolbarItemIdentifier];

@implementation AppController (TheRest)
{
  CPTextField      _bitlyUrlLabel;
  CPToolbarItem    _bitlyToolbarItem;
  CPToolbar        _toolBar;
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
  // initialise the placeholder, this then gets the images.
  [PlaceholderManager sharedInstance];
  // check the communication to the server
  [[CommunicationManager sharedInstance] ping:[ConfigurationManager sharedInstance] 
                                     selector:@selector(publishRequestCompleted:)];

  var theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() 
                                              styleMask:CPBorderlessBridgeWindowMask],
    contentView = [theWindow contentView],
    bounds = [contentView bounds];

  _toolBar = [[CPToolbar alloc] initWithIdentifier:"PubEditor"];
  [_toolBar setDelegate:self];
  [_toolBar setVisible:true];
  [theWindow setToolbar:_toolBar];

  var sideBarWidth = [ThemeManager sideBarWidth];

  // page numbers control box
  var pageCtrl = [PageViewController 
                   createPageControlView:CGRectMake(0, 0, sideBarWidth, 30)];

  [contentView addSubview:pageCtrl];

  // page number listing 
  var listPageNumbersView = [PageViewController 
                              createListPageNumbersView:CGRectMake(0, 0, sideBarWidth, 0)];
  [[PageViewController sharedInstance] sendOffRequestForPageNames];

  var pageListScrollView = [[CPScrollView alloc] 
                             initWithFrame:CGRectMake(0, 0, sideBarWidth, 200)];
  [pageListScrollView setAutohidesScrollers:YES];
  [pageListScrollView setAutoresizingMask:CPViewHeightSizable];
  [pageListScrollView setDocumentView:listPageNumbersView];

  [pageListScrollView setBackgroundColor:[ThemeManager bgColorPageListView]];

  // Tools scroll view. -- "meta data view"
  var toolsScrollView = [[CPScrollView alloc] 
                          initWithFrame:CGRectMake(0, 0, sideBarWidth, 400)];
  [toolsScrollView setAutohidesScrollers:YES];
  [toolsScrollView setAutoresizingMask:CPViewHeightSizable];
  [[toolsScrollView contentView] setBackgroundColor:[ThemeManager bgColorToolView]];
  [toolsScrollView setDocumentView:[ToolViewController 
                                     createToolsCollectionView:CGRectMake(0, 0, sideBarWidth, 0)]];

  var splitView = [[CPSplitView alloc] 
                    initWithFrame:CGRectMake(0, 30, 
                                             sideBarWidth, 
                                             CGRectGetHeight(bounds) - 88)];
  [splitView setVertical:NO];
  [splitView addSubview:pageListScrollView];
  [splitView addSubview:toolsScrollView];
  [splitView setAutoresizingMask:CPViewHeightSizable];
  [contentView addSubview:splitView];
  
  /*
   * DIN A4 size in pixels based on dpi (portrait):
   * 210mm = 8.2677165354 in == width
   * 297mm = 11.6929133739 in == height
   */
  var dpi = [[ConfigurationManager sharedInstance] dpi];
  if ( isNaN(dpi) ) dpi = 96;
  var rectA4 = CGRectMake(40, 40, 8.2677165354*dpi, 11.6929133739*dpi);

  // bgView provides the border of the document view. we move the document view in 
  // by 40px on each side.
  var rectBgView = CGRectMake(0, 0, CGRectGetWidth(rectA4)+80, CGRectGetHeight(rectA4)+80)
  var bgView = [[CPView alloc] initWithFrame:rectBgView];
  [bgView setAutoresizesSubviews:NO];
  [bgView setAutoresizingMask:CPViewNotSizable];
  var shadowView = [[CPShadowView alloc] initWithFrame:CGRectInset(rectA4, -7, -5)];
  [shadowView setAutoresizingMask:CPViewNotSizable];
  [shadowView setWeight:CPHeavyShadow];

  [bgView addSubview:shadowView];
  [bgView addSubview:[DocumentViewController createDocumentView:rectA4]];
  
  var pubScrollView = [[CPScrollView alloc] initWithFrame:CGRectMake(1, 0, // 1 for the border
                                                          CGRectGetWidth(bounds) - sideBarWidth, 
                                                          CGRectGetHeight(bounds) - 58)];
  [pubScrollView setBackgroundColor:[ThemeManager bgColorContentView]];
  [pubScrollView setAutoresizingMask:(CPViewHeightSizable | CPViewWidthSizable)];
  [pubScrollView setDocumentView:bgView];
  [pubScrollView setAutohidesScrollers:YES];
  [pubScrollView setAutoresizesSubviews:NO];

  var borderBox = [[CPBox alloc] initWithFrame:CGRectMake(sideBarWidth, 0, 
                                                           CGRectGetWidth(bounds) - sideBarWidth, 
                                                           CGRectGetHeight(bounds) - 58)];
  [borderBox setBorderWidth:1.0];
  [borderBox setBorderColor:[ThemeManager borderColor]];
  [borderBox setBorderType:CPLineBorder];
  [borderBox setFillColor:[CPColor whiteColor]];
  [borderBox setAutoresizingMask:CPViewHeightSizable | CPViewWidthSizable];
  [borderBox addSubview:pubScrollView];

  [contentView addSubview:borderBox];
  [theWindow orderFront:self];
}

//
// Actions
//

- (void)showHideFlickr:(id)sender
{
  var controller = [FlickrController alloc];
  [controller initWithWindowCibName:FlickrCIB owner:controller];
  [controller showWindow:self];
}

- (void)showHideTwitter:(id)sender
{
  var controller = [TwitterController alloc];
  [controller initWithWindowCibName:TwitterCIB];
  [controller showWindow:self];
}

- (void)showHideYouTube:(id)sender
{
  var controller = [YouTubeController alloc];
  [controller initWithWindowCibName:YouTubeCIB owner:controller];
  [controller showWindow:self];
}

- (void)showHideFacebook:(id)sender
{
  var controller = [FacebookController alloc];
  [controller initWithWindowCibName:FacebookCIB owner:controller];
  [controller showWindow:self];
}

- (void)showHideGoogleImages:(id)sender
{
  var controller = [GoogleImagesController alloc];
  [controller initWithWindowCibName:GoogleImagesCIB owner:controller];
  [controller showWindow:self];
}

- (void)publishPublication:(id)sender
{
  [[CommunicationManager sharedInstance] 
    publishWithDelegate:self
               selector:@selector(publishRequestCompleted:)];
}

- (void)publishPublicationHtml:(id)sender
{
  [[CommunicationManager sharedInstance] 
    publishInHtmlWithDelegate:self
                     selector:@selector(publishRequestCompleted:)];
}

- (void)showTodoMsg:(id)sender
{
  alertUserWithTodo("This has yet to be implemented but the monkeys are busy!");
}


//
// Helpers
//

- (void)publishRequestCompleted:(JSObject)data
{
  CPLogConsole( "[AppCon] [Publish] got action: " + data.action );
  switch ( data.action ) {
  case "publications_publish":
    if ( data.status == "ok" ) {
      alertUserOfPublicationUrl(data.data.bitly.short_url,data.data.bitly.hash);
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

  case GoogleImagesWindowControlItemIdentifier:
    [toolbarItem setImage:[PlaceholderManager imageFor:'googleImages']];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:'googleImagesHigh']];
        
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showHideGoogleImages:)];

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

  case DiggToolbarItemIdentifier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"digg"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"diggHigh"]];
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showTodoMsg:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case StumbleuponToolbarItemIdentifier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"stumbleupon"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"stumbleuponHigh"]];
    [toolbarItem setTarget:self];
    //[toolbarItem setAction:@selector(showHideStumbleupon:)];
    [toolbarItem setAction:@selector(showTodoMsg:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case PublishPublicationToolbarItemIdentifier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"pdf"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"pdfHigh"]];

    [toolbarItem setTarget:self];
    //[toolbarItem setAction:@selector(publishPublication:)];
    [toolbarItem setAction:@selector(showTodoMsg:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case PublishPublicationHtmlToolbarItemIdentifier:
    [toolbarItem setImage:[PlaceholderManager imageFor:@"html"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"htmlHigh"]];
    [toolbarItem setLabel:"Publish"];

    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(publishPublicationHtml:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;
  }

  return toolbarItem;
}

@end


