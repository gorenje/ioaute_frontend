/*
  This stores a bunch of placeholders, required at various places in the application.
*/
var ConfigurationManagerInstance = nil;

@implementation ConfigurationManager : CPObject
{
  CPDictionary _cookieStore;
  CPString pageNumber @accessors;
}

- (id)init
{
  self = [super init];
  if (self) {
    _cookieStore = [[CPDictionary alloc] init];
    pageNumber = "1";
  }
  return self;
}

//
// Singleton class, this provides the callee with the only instance of this class.
//
+ (ConfigurationManager) sharedInstance 
{
  if ( !ConfigurationManagerInstance ) {
    ConfigurationManagerInstance = [[ConfigurationManager alloc] init];
  }
  return ConfigurationManagerInstance;
}

//
// Instance methods.
//

- (CPObject)valueFor:(CPString)name
{
  if ( !name || name == "" ) return;

  var val = [_cookieStore objectForKey:name];
  if ( !val ) {
    var cookie = [[CPCookie alloc] initWithName:name];
    if ( cookie ) {
      val = cookie;
      CPLogConsole( "[CONFIG] Found value '" + [val value] + "' for '" + name + "'");
      [_cookieStore setObject:cookie forKey:name];
    } else {
      CPLogConsole( "[CONFIG] ERROR No cookie found for '" + name + "'");
    }
  }
  return [val value];
}

- (CPString)fbCookie
{
  // TODO the facebook application id is hardcoded here ....
  // TODO replaced with the new app: 163279683716657
  // TODO localhost app is 152086648173411
  var cookie = [self valueFor:"fbs_" + "163279683716657"];
  // Strangely the cookie value is encased in quote marks.
  cookie = cookie.replace(/^"/,'').replace(/"$/,'');
  CPLogConsole( "FB Cookie: " + cookie);
  return cookie;
}

- (CPString)server
{
  // The server URL is being sent URL-encoded, decode it.
  return unescape([self valueFor:"server"]);
}

- (CPString)publication_id
{
  return [self valueFor:"publication_id"];
}

- (int)dpi
{
  return parseInt([self valueFor:"dpi"]);
}

@end
