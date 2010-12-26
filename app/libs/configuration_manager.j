/*
  This stores a bunch of placeholders, required at various places in the application.
*/
@import <Foundation/CPObject.j>

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

- (CPString)server
{
  // The server URL is being sent URL-encoded, decode it.
  //return unescape([self valueFor:"server"]);
  // TODO THIS IS ONLY FOR DEBUG
  return "http://localhost:3000/publications";
}

- (CPString)publication_id
{
  return "abcd1sd112";
  // return [self valueFor:"publication_id"];
}

@end
