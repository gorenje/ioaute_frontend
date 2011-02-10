/*
 * All good things Javascript. All the various helpers that we require (i.e. those
 * things that aren't a method) can be defined here.
 */

// This takes a query string NOT a complete GET url.
// TODO should put this into a helpers class?
function getQueryVariables(query_str) {
  var store = [[CPDictionary alloc] init];
  var vars = query_str.split("&");
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
    [store setObject:pair[1] forKey:pair[0]];
  } 
  return store;
}

function queryStringFromUrl(urlString) {
  return urlString.split("?")[1];
}

function getVideoIdFromYouTubeUrl(urlString) {
  var queryString = queryStringFromUrl(urlString);
  if ( queryString ) {
    var store = getQueryVariables(queryString);
    return [store objectForKey:@"v"];
  } else {
    return nil;
  }
}

function alertUserWithTodo(msg) {
  var alert = [[CPAlert alloc] init];
  [alert setMessageText:msg];
  [alert setTitle:@"Todo"];
  [alert setAlertStyle:CPInformationalAlertStyle];
  [alert addButtonWithTitle:@"OK"];
  [alert runModal];
}

function alertUserOfPublicationUrl(urlStr, hshStr) {
  var alert = [[CPAlert alloc] init];
  [alert setEnabled:YES];
  [alert setSelectable:YES];
  [alert setEditable:NO];
  [alert setMessageText:[CPString 
                          stringWithFormat:("Publication can be found here %s. Press "+
                                            "Open to open link in a new popup window."), 
                                  urlStr]];
  [alert setTitle:@"Publication Preview"];
  [alert setAlertStyle:CPInformationalAlertStyle];
  [alert setDelegate:[[UrlAlertDelegate alloc] initWithUrlStr:urlStr andHashStr:hshStr]];
  [alert addButtonWithTitle:@"Open"];
  [alert addButtonWithTitle:@"Close"];
  [alert runModal];
}

function alertUserOfPublicationPreviewUrl(urlStr) {
  var alert = [[CPAlert alloc] init];
  [alert setEnabled:YES];
  [alert setSelectable:YES];
  [alert setEditable:NO];
  [alert setMessageText:@"Press open to preview in a new popup window."];
  [alert setTitle:@"Publication Preview"];
  [alert setAlertStyle:CPInformationalAlertStyle];
  [alert setDelegate:[[UrlAlertDelegate alloc] 
                       initWithUrlStr:urlStr 
                           andHashStr:("PubmePreview"+urlStr)]];
  [alert addButtonWithTitle:@"Open"];
  [alert addButtonWithTitle:@"Close"];
  [alert runModal];
}

function alertUserGoingBack(urlStr, hshStr) {
  var alert = [[CPAlert alloc] init];
  [alert setEnabled:YES];
  [alert setSelectable:YES];
  [alert setEditable:NO];
  [alert setMessageText:"Quit editing and require to publication list?"];
  [alert setTitle:@"Quit Editor"];
  [alert setAlertStyle:CPWarningAlertStyle];
  [alert setDelegate:[[UrlAlertDelegate alloc] initWithUrlStr:urlStr]];
  [alert addButtonWithTitle:@"Yes"];
  [alert addButtonWithTitle:@"Cancel"];
  [alert runModal];
}

function alertUserOfCrash() {
  var alert = [[CPAlert alloc] init];
  [alert setEnabled:YES];
  [alert setSelectable:YES];
  [alert setEditable:NO];
  [alert setMessageText:("We're are sorry but editor will need restarting. This is "+
                         "for your own protection as an internal inconsistency has "+
                         "been identified. If this continues, please contact us immediately.")];
  [alert setTitle:@"Fatal Blue Screen"];
  [alert setAlertStyle:CPCriticalAlertStyle];
  [alert setDelegate:[ReloadDelegate reloadWithLove]];
  [alert addButtonWithTitle:@"Restart"];
  [alert addButtonWithTitle:@"No thfanks!"];
  [alert runModal];
}

function decodeCgi(str) {
  // this assumes that '+' is a space. unescape only seems to unescape %xy escapes.
  return unescape(str.replace(/\+/g, " "));
}

function rectToString(rect) {
  return ("[Origin.x: " + rect.origin.x + " y: " + rect.origin.y + " width: " + 
          rect.size.width + " height: " + rect.size.height + "]");
}

@implementation ReloadDelegate : CPObject 

+ (id)reloadWithLove
{
  return [[ReloadDelegate alloc] init];
}

- (id)init
{
  self = [super init];
  return self;
}

-(void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
  CPLogConsole( "Return Code was: " + returnCode );
  switch ( returnCode ) {
  case 0: // Restart
    window.location.reload();
    break;
  }
}

@end

@implementation UrlAlertDelegate : CPObject 
{
  CPString _urlString;
  CPString _hshString;
}

- (id)initWithUrlStr:(CPString)urlStr
{
  return [self initWithUrlStr:urlStr andHashStr:nil];
}

- (id)initWithUrlStr:(CPString)urlStr andHashStr:(CPString)hshStr
{
  self = [super init];
  if ( self ) {
    _urlString = urlStr;
    _hshString = hshStr;
  }
  return self;
}

-(void)alertDidEnd:(CPAlert)theAlert returnCode:(int)returnCode
{
  CPLogConsole( "Return Code was: " + returnCode );
  switch ( returnCode ) {
  case 0: // Open
    if ( _hshString ) {
      window.open(_urlString, _hshString, '');
    } else {
      window.location = _urlString;
    }
    break;
  }
}

@end

@implementation CPAlert (MakeSelectable)

- (void) setEnabled:(BOOL)flag
{
  [_messageLabel setEnabled:flag];
}

- (void) setSelectable:(BOOL)flag
{
  [_messageLabel setSelectable:flag];
}

- (void) setEditable:(BOOL)flag
{
  [_messageLabel setEditable:flag];
}

- (void) close
{
  [CPApp abortModal];
  [_alertPanel close];
}

@end

@implementation CPString (IsBlank)

- (BOOL)isBlank
{
  // TODO this is needs to be done better
  return (self == "");
}

@end

@implementation CPArray (RandomValueFromArray)

/*
 * Return any object that is currently contained in the array.
 */
- (CPObject)anyValue
{
  var idx = Math.floor(Math.random() * ([self count]+1));
  // idx is [self count] when Math.random() == 1
  return (self[idx] || self[0]);
}

@end

@implementation CPColor (ColorWithEightBit)

/*
 * Instead of float values, we use integer values from 0 to 255 (incl.) for the RGB
 * components. Alpha remains a float value from 0.0 to 1.0.
 */
+ (CPColor) colorWith8BitRed:(int)red green:(int)green blue:(int)blue alpha:(float)alpha
{
  return [CPColor colorWithRed:red/255.0 green:green/255.0 blue:blue/255.0 alpha:alpha];
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

@implementation CPBox (BorderedBox)

+ (CPBox)makeBorder:(CPView)aView
{
  var box = [CPBox boxEnclosingView:aView];
  [box setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [box setBorderColor:[CPColor colorWithHexString:@"a9aaae"]];
  [box setBorderType:CPLineBorder];
}

@end

@implementation AppController (Helpers)

- (CPTextField) createBitlyInfoBox:(CGRect)aRect
{
  var textField = [[CPTextField alloc] initWithFrame:aRect];
  [textField setStringValue:@""];
  [textField setSelectable:NO];
  [textField setEditable:NO];
  [textField setAlignment:CPCenterTextAlignment];
  [textField setVerticalAlignment:CPCenterVerticalTextAlignment];
  [textField setFont:[CPFont systemFontOfSize:12.0]];
  [textField setTextShadowColor:[CPColor blueColor]];
  [textField setTextShadowOffset:CGSizeMake(0, 1)];
  return textField;
}

@end
