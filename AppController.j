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
ConfigurationManagerToolBarArrivedNotification = @"ConfigurationManagerToolBarArrivedNotification";
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
YouTubeVideoPropertyWindowCIB  = @"YouTubeVideoProperties";

/*
 * BTW mini-intro into cappuccino:
 *  var Fubar = ...; // this is a "file-wide" variable, i.e. only usable in this file.
 *  Snafu = ...; // this is a global variable, i.e. usable everywhere.
 *
 * Another thing is the usage of @"...string..." and "...string...". These are
 * equivalent in Objective-J but not in Obj-C. Basically this is a back-port and
 * most Obj-C programmers use @"..." and the rest of us use "...".
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
// mixins
@import "app/helpers/mixin_helper.j"
@import "app/models/mixins/page_element_color_support.j"
@import "app/models/mixins/page_element_size_support.j"
@import "app/models/mixins/page_element_font_support.j"
@import "app/models/mixins/you_tube_video_properties.j"
@import "app/models/mixins/you_tube_page_element.j"
@import "app/models/mixins/image_element_properties.j"
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
@import "app/models/you_tube_t_e.j"
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
@import "app/controllers/properties/property_you_tube_video_controller.j"

@implementation AppController (TheRest)
{
  CPTextField   _bitlyUrlLabel;
  CPToolbarItem _bitlyToolbarItem;
  CPToolbar     m_toolBar;
  CPArray       m_toolBarItems;
}

- (void)toolBarItemsHaveArrived:(CPNotification)aNotification
{
  m_toolBarItems = [aNotification object];
  [m_toolBar setDelegate:self];
  [m_toolBar setVisible:true];
}

- (void)applicationDidFinishLaunching:(CPNotification)aNotification
{
  m_toolBarItems = [];
  // initialise the placeholder, this then gets the images.
  [PlaceholderManager sharedInstance];

  // ping should trigger the following notification.
  [[CPNotificationCenter defaultCenter]
          addObserver:self
             selector:@selector(toolBarItemsHaveArrived:)
                 name:ConfigurationManagerToolBarArrivedNotification
               object:nil]; // object is a list of tool box items
  
  // check the communication to the server
  [[CommunicationManager sharedInstance] ping:[ConfigurationManager sharedInstance] 
                                     selector:@selector(publishRequestCompleted:)];

  theWindow = [[CPWindow alloc] initWithContentRect:CGRectMakeZero() 
                                            styleMask:CPBorderlessBridgeWindowMask];
  var contentView = [theWindow contentView],
    bounds = [contentView bounds];

  m_toolBar = [[CPToolbar alloc] initWithIdentifier:"PubEditor"];
  [theWindow setToolbar:m_toolBar];

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

  var pubScrollView = [[CPScrollView alloc] 
                        initWithFrame:CGRectMake(1, 0, // 1 for the border
                                                 CGRectGetWidth(bounds) - sideBarWidth, 
                                                 CGRectGetHeight(bounds) - 58)];
  [pubScrollView setBackgroundColor:[ThemeManager bgColorContentView]];
  [pubScrollView setAutoresizingMask:(CPViewHeightSizable | CPViewWidthSizable)];
  [pubScrollView setDocumentView:[DocumentViewController createDocumentView]];
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

- (void)previewPublicationHtml:(id)sender
{
  alertUserOfPublicationPreviewUrl([CPString stringWithFormat:"%s/%s", 
                                             [[ConfigurationManager sharedInstance] server],
                                             [[ConfigurationManager sharedInstance] publication_id]]);
}

- (void)backButtonPressed:(id)sender
{
  alertUserGoingBack([CPString stringWithFormat:"%s/user", 
                               [[ConfigurationManager sharedInstance] server]]);
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
  return m_toolBarItems;
}

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar 
   itemForItemIdentifier:(CPString)anItemIdentifier 
willBeInsertedIntoToolbar:(BOOL)aFlag
{
  var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];

  switch ( anItemIdentifier ) {

  case "BitlyUrlToolbarItemIdentifier":
    _bitlyUrlLabel = [self createBitlyInfoBox:CGRectMake(0, 0, 0, 32)];
    _bitlyToolbarItem = toolbarItem;
    [toolbarItem setView:_bitlyUrlLabel];
    [toolbarItem setMinSize:CGSizeMake(120, 32)];
    [toolbarItem setMaxSize:CGSizeMake(120, 32)];
    [toolbarItem setLabel:nil];
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(redirectToBitly:)];
    break;
    
  case "GoogleImagesWindowControlItemIdentifier":
    [toolbarItem setImage:[PlaceholderManager imageFor:'googleImages']];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:'googleImagesHigh']];
        
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showHideGoogleImages:)];

    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case "FlickrWindowControlItemIdentifier":
    [toolbarItem setImage:[PlaceholderManager imageFor:'flickr']];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:'flickrHigh']];
        
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showHideFlickr:)];

    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case "TwitterWindowControlItemIdentifier":
    [toolbarItem setImage:[PlaceholderManager imageFor:@"twitter"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"twitterHigh"]];
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showHideTwitter:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case "FacebookToolbarItemIdentifier":
    [toolbarItem setImage:[PlaceholderManager imageFor:@"facebook"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"facebookHigh"]];
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showHideFacebook:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case "YouTubeToolbarItemIdentifier":
    [toolbarItem setImage:[PlaceholderManager imageFor:@"youtube"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"youtubeHigh"]];
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showHideYouTube:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case "DiggToolbarItemIdentifier":
    [toolbarItem setImage:[PlaceholderManager imageFor:@"digg"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"diggHigh"]];
    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(showTodoMsg:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case "StumbleuponToolbarItemIdentifier":
    [toolbarItem setImage:[PlaceholderManager imageFor:@"stumbleupon"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"stumbleuponHigh"]];
    [toolbarItem setTarget:self];
    //[toolbarItem setAction:@selector(showHideStumbleupon:)];
    [toolbarItem setAction:@selector(showTodoMsg:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case "PublishPublicationToolbarItemIdentifier":
    [toolbarItem setImage:[PlaceholderManager imageFor:@"pdf"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"pdfHigh"]];

    [toolbarItem setTarget:self];
    //[toolbarItem setAction:@selector(publishPublication:)];
    [toolbarItem setAction:@selector(showTodoMsg:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case "PublishPublicationHtmlToolbarItemIdentifier":
    [toolbarItem setImage:[PlaceholderManager imageFor:@"html"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"htmlHigh"]];
    [toolbarItem setLabel:"Publish"];

    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(publishPublicationHtml:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case "PreviewPublicationHtmlToolbarItemIdentifier":
    [toolbarItem setImage:[PlaceholderManager imageFor:@"html"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"htmlHigh"]];
    [toolbarItem setLabel:"Preview"];

    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(previewPublicationHtml:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case "BackToPublicationsControlItemIdentifier":
    [toolbarItem setImage:[PlaceholderManager imageFor:@"backButton"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"backButtonHigh"]];
    [toolbarItem setLabel:"Back"];

    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(backButtonPressed:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;
  }

  return toolbarItem;
}

@end
