
/*
 * If a new drag type is added, then ensure that the DragDropManager knows about it.
 * The DD-Manager can then be used as a store for the data being dragged and dropped.
 */
TweetDragType = @"TweetDragType";
FlickrDragType = @"FlickrDragType";

@import <Foundation/CPObject.j>
@import <AppKit/CPCookie.j>

@import "app/helpers/application_helpers.j"
@import "app/libs/drag_drop_manager.j"
@import "app/libs/placeholder_manager.j"
@import "app/libs/configuration_manager.j"
@import "app/libs/communication_manager.j"
@import "app/models/page_element.j"
@import "app/models/tweet.j"
@import "app/models/flickr.j"
@import "app/views/document_view.j"
@import "app/views/document_view_cell.j"
@import "app/views/document_view_editor_view.j"
@import "app/views/flickr_photo_cell.j"
@import "app/views/flickr_photo_view.j"
@import "app/controllers/twitter_controller.j"
@import "app/controllers/flickr_controller.j"

var ZoomToolbarItemIdentifier = "ZoomToolbarItemIdentifier",
  AddPageToolbarItemIdentifier = "AddPageToolbarItemIdentifier",
  FlickrWindowControlItemIdentfier = "FlickrWindowControlItemIdentfier",
  TwitterWindowControlItemIdentfier = "TwitterWindowControlItemIdentfier",
  RemovePageToolbarItemIdentifier = "RemovePageToolbarItemIdentifier";

var ToolBarItems = [AddPageToolbarItemIdentifier, 
                    RemovePageToolbarItemIdentifier, 
                    FlickrWindowControlItemIdentfier,
                    TwitterWindowControlItemIdentfier,
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

  [pubScrollView setAutoresizingMask:(CPViewHeightSizable|CPViewWidthSizable)];
  [pubScrollView setDocumentView:_documentView];
  [pubScrollView setAutohidesScrollers:YES];
  [[pubScrollView contentView] setBackgroundColor:[CPColor colorWithCalibratedWhite:0.25 
                                                                           alpha:1.0]];
  [contentView addSubview:pubScrollView];
  [theWindow orderFront:self];
}

- (void)addPage:(id)sender
{
  var string = prompt("New Page Name");

  if (string)
  {
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

- (void)showHideFlickr:(id)sender
{
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

//this delegate method returns the actual toolbar item for the given identifier

- (CPToolbarItem)toolbar:(CPToolbar)aToolbar itemForItemIdentifier:(CPString)anItemIdentifier willBeInsertedIntoToolbar:(BOOL)aFlag
{
  var toolbarItem = [[CPToolbarItem alloc] initWithItemIdentifier:anItemIdentifier];

  switch ( anItemIdentifier ) {

  case ZoomToolbarItemIdentifier:
    [toolbarItem setView:[[PhotoResizeView alloc] initWithFrame:CGRectMake(0, 0, 180, 32)]];
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
  }

  return toolbarItem;
}

@end


@implementation PageNumberListCell : CPView
{
  CPTextField     label;
  CPView          highlightView;
}

- (void)setRepresentedObject:(JSObject)anObject
{
  if(!label)
  {
    label = [[CPTextField alloc] initWithFrame:CGRectInset([self bounds], 4, 4)];
        
    [label setFont:[CPFont systemFontOfSize:16.0]];
    [label setTextShadowColor:[CPColor whiteColor]];
    [label setTextShadowOffset:CGSizeMake(0, 1)];

    [self addSubview:label];
  }

  [label setStringValue:anObject];
  [label sizeToFit];

  [label setFrameOrigin:CGPointMake(10,CGRectGetHeight([label bounds]) / 2.0)];
}

- (void)setSelected:(BOOL)flag
{
  if(!highlightView)
  {
    highlightView = [[CPView alloc] initWithFrame:CGRectCreateCopy([self bounds])];
    [highlightView setBackgroundColor:[CPColor blueColor]];
  }

  if(flag)
  {
    [self addSubview:highlightView positioned:CPWindowBelow relativeTo:label];
    [label setTextColor:[CPColor whiteColor]];    
    [label setTextShadowColor:[CPColor blackColor]];
  }
  else
  {
    [highlightView removeFromSuperview];
    [label setTextColor:[CPColor blackColor]];
    [label setTextShadowColor:[CPColor whiteColor]];
  }
}

@end

@implementation PhotoResizeView : CPView
{
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];
    
  var slider = [[CPSlider alloc] initWithFrame:CGRectMake(30, CGRectGetHeight(aFrame)/2.0 - 8, CGRectGetWidth(aFrame) - 65, 24)];

  [slider setMinValue:50.0];
  [slider setMaxValue:250.0];
  [slider setIntValue:150.0];
  [slider setAction:@selector(adjustPublicationZoom:)];
    
  [self addSubview:slider];
                                                             
  var label = [CPTextField flickr_labelWithText:"50"];
  [label setFrameOrigin:CGPointMake(0, CGRectGetHeight(aFrame)/2.0 - 4.0)];
  [self addSubview:label];

  label = [CPTextField flickr_labelWithText:"250"];
  [label setFrameOrigin:CGPointMake(CGRectGetWidth(aFrame) - CGRectGetWidth([label frame]), CGRectGetHeight(aFrame)/2.0 - 4.0)];
  [self addSubview:label];
    
  return self;
}

@end

@implementation CPTextField (CreateLabel)

+ (CPTextField)flickr_labelWithText:(CPString)aString
{
    var label = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
    
    [label setStringValue:aString];
    [label sizeToFit];
    [label setTextShadowColor:[CPColor whiteColor]];
    [label setTextShadowOffset:CGSizeMake(0, 1)];
    
    return label;
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
