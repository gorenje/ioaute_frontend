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
  [alert setMessageText:[CPString stringWithFormat:@"Publication preview can be found here %s. Press Open to open link in a new popup window.", urlStr]];
  [alert setTitle:@"Publication Preview"];
  [alert setAlertStyle:CPInformationalAlertStyle];
  [alert setDelegate:[[UrlAlertDelegate alloc] initWithUrlStr:urlStr andHashStr:hshStr]];
  [alert addButtonWithTitle:@"Open"];
  //[alert addButtonWithTitle:@"Copy"];
  [alert addButtonWithTitle:@"Close"];
  [alert runModal];
}

function decodeCgi(str) {
  return unescape(str.replace(/\+/g, " "));
}

@implementation UrlAlertDelegate : CPObject 
{
  CPString _urlString;
  CPString _hshString;
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
  case 2: // Close
    break;
  case 1: // Copy
//     var pasteboard = [CPPasteboard generalPasteboard];
//     [pasteboard declareTypes:[CPStringPboardType] owner:nil];
//     [pasteboard setString:_urlString forType:CPStringPboardType];
//     [pasteboard _synchronizePasteboard];
    break;
  case 0:
    window.open(_urlString, _hshString, '');
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

@end

@implementation CPString (IsBlank)

- (BOOL)isBlank
{
  // TODO this is needs to be done better
  return (self == "");
}

@end

@implementation CPArray (RandomValueFromArray)

- (CPObject)anyValue
{
  if ( self.length == 0 ) 
    return nil;

  var idx = Math.floor(Math.random() * (self.length+1));
  return self[idx];
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
