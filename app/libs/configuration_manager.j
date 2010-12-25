/*
  This stores a bunch of placeholders, required at various places in the application.
*/
@import <Foundation/CPObject.j>

var ConfigurationManagerInstance = nil;

@implementation ConfigurationManager : CPObject
{
  CPDictionary _store;
}

- (id)init
{
  self = [super init];
  if (self) {
    _store = [[CPDictionary alloc] init];
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

  var val = [_store objectForKey:name];
  if ( !val ) {
    var cookie = [[CPCookie alloc] initWithName:name];
    if ( cookie ) {
      val = cookie;
      CPLogConsole( "[CONFIG] Found value '" + [val value] + "' for '" + name + "'");
      [_store setObject:cookie forKey:name];
    } else {
      CPLogConsole( "[CONFIG] ERROR No cookie found for '" + name + "'");
    }
  }
  return [val value];
}

- (CPString)server
{
  // The server URL is set being URL-encoded, decode it.
  return unescape([self valueFor:"server"]);
}

- (CPString)publication_id
{
  return [self valueFor:"publication_id"];
}

@end
