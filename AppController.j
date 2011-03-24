/*
 * Created by Gerrit Riessen
 * Copyright 2010-2011, Gerrit Riessen
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
/*
 * If a new drag type is added, then ensure that the DragDropManager knows about it.
 * The DD-Manager can then be used as a store for the data being dragged and dropped.
 */
TweetDragType        = @"TweetDragType";
FlickrDragType       = @"FlickrDragType";
FacebookDragType     = @"FacebookDragType";
YouTubeDragType      = @"YouTubeDragType";
ToolElementDragType  = @"ToolElementDragType";
GoogleImagesDragType = @"GoogleImagesDragType";
PageNumberDragType   = @"PageNumberDragType";

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
PageElementWantsToBeDeletedNotification = @"PageElementWantsToBeDeletedNotification"; 

/*
 * CIBs used for various windows.
 */
// Search windows.
var FlickrCIB     = @"FlickrWindow",
  FacebookCIB     = @"FacebookWindow",
  YouTubeCIB      = @"YouTubeWindow",
  GoogleImagesCIB = @"GoogleImagesWindow",
  TwitterCIB      = @"TwitterWindow",
  PublicationPropCIB = @"PublicationProperties";

// Property windows.
LinkTEPropertyWindowCIB        = @"LinkTEProperties";
HighlightTEPropertyWindowCIB   = @"HighlightTEProperties";
ImageTEPropertyWindowCIB       = @"ImageTEProperties";
TwitterFeedTEPropertyWindowCIB = @"TwitterFeedTEProperties";
TextTEPropertyWindowCIB        = @"TextTEProperties";
PagePropertyWindowCIB          = @"PageProperties";
YouTubeVideoPropertyWindowCIB  = @"YouTubeVideoProperties";
PayPalButtonPropertyWindowCIB  = @"PayPalButtonProperties";
YouTubeSeekToLinkTEPropertyWindowCIB = @"YouTubeSeekToLinkTEProperties";

var CopiedPageElement = nil;

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
@import <AppKit/CPView.j>
@import <TNKit/TNKit.j>
@import <TNKit/TNToolTip.j>
@import <TNKit/TNCategories.j>
@import <LPKit/LPKit.j>
@import <LPKit/LPMultiLineTextField.j>
@import <LPKit/LPURLPostRequest.j>

/*
 * The application_helpers.j define a number of helper methods for the AppController
 * hence we need to pre-define the class.
 */
@implementation AppController : CPObject
@end

@import "app/editor.j"

@implementation AppController (TheRest)
{
  CPToolbar    m_toolBar;
  CPArray      m_toolBarItems;
  CPDictionary m_toolBarTips
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
  var pubConfig = [[ConfigurationManager sharedInstance] pubProperties];

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
  [pageListScrollView setHasHorizontalScroller:NO];
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
  [pubConfig setPubBgView:pubScrollView];

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
// Notifications
//
- (void)toolBarItemsHaveArrived:(CPNotification)aNotification
{
  m_toolBarItems = [aNotification object][0];
  m_toolBarTips = [aNotification object][1];
  [m_toolBar setDelegate:self];
  [m_toolBar setVisible:true];
}

//
// Actions
//

- (void)showHideFlickr:(id)sender
{
  var controller = [FlickrController alloc];
  [controller initWithWindowCibName:FlickrCIB];
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
  [controller initWithWindowCibName:YouTubeCIB];
  [controller showWindow:self];
}

- (void)showHideFacebook:(id)sender
{
  var controller = [FacebookController alloc];
  [controller initWithWindowCibName:FacebookCIB];
  [controller showWindow:self];
}

- (void)showHideGoogleImages:(id)sender
{
  var controller = [GoogleImagesController alloc];
  [controller initWithWindowCibName:GoogleImagesCIB];
  [controller showWindow:self];
}

- (void)previewPublicationHtml:(id)sender
{
  [AlertUserHelper ofPublicationPreviewUrl:[ConfigurationManager previewUrl]];
}

- (void)backButtonPressed:(id)sender
{
  [AlertUserHelper goingBack:[ConfigurationManager goingBackUrl]];
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
  [AlertUserHelper 
    withTodo:"This has yet to be implemented but the monkeys are busy!"];
}

- (void)copyButtonPressed:(id)sender
{
  CopiedPageElement = [[[DocumentViewEditorView sharedInstance] 
                         documentViewCell] pageElement];
}

- (void)pasteButtonPressed:(id)sender
{
  if ( CopiedPageElement ) {
    [[CommunicationManager sharedInstance] 
      copyElement:CopiedPageElement];
  }
}

- (void)publicationPropertyButtonPressed:(id)sender
{
  var controller = [PropertyPublicationController alloc];
  [controller initWithWindowCibName:PublicationPropCIB owner:controller];
  [controller showWindow:self];
}

//
// Helpers
//

- (void)publishRequestCompleted:(JSObject)data
{
  switch ( data.action ) {
  case "publications_publish":
    if ( data.status == "ok" ) {
      [AlertUserHelper ofPublicationUrl:data.data.bitly.short_url
                                hashStr:data.data.bitly.hash];
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
  var toolbarItem = [[CPToolbarItem alloc] 
                      initWithItemIdentifier:anItemIdentifier];
  [toolbarItem setToolTip:m_toolBarTips[anItemIdentifier]];

  switch ( anItemIdentifier ) {

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

  case "CopyPageElementControlItemIdentifier":
    [toolbarItem setImage:[PlaceholderManager imageFor:@"menuCopyButton"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"menuCopyButtonHigh"]];
    [toolbarItem setLabel:"Copy"];

    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(copyButtonPressed:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case "PastePageElementControlItemIdentifier":
    [toolbarItem setImage:[PlaceholderManager imageFor:@"menuPasteButton"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"menuPasteButtonHigh"]];
    [toolbarItem setLabel:"Paste"];

    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(pasteButtonPressed:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  case "PublicationPropertyControlItemIdentifier":
    [toolbarItem setImage:[PlaceholderManager imageFor:@"propertyPublicationButton"]];
    [toolbarItem setAlternateImage:[PlaceholderManager imageFor:@"propertyPublicationButtonHigh"]];
    [toolbarItem setLabel:"Property"];

    [toolbarItem setTarget:self];
    [toolbarItem setAction:@selector(publicationPropertyButtonPressed:)];
    [toolbarItem setMinSize:CGSizeMake(32, 32)];
    [toolbarItem setMaxSize:CGSizeMake(32, 32)];
    break;

  }

  return toolbarItem;
}

@end
