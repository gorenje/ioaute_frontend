/*
  This stores a bunch of placeholders, required at various places in the application.
*/
var ConfigurationManagerInstance = nil;

/*
 * Cache the array created from the publication topics cookie
 */
var PublicationTopicArray = nil;

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
  return decodeCgi([self valueFor:"server"]);
}

- (CPString)publication_id
{
  return decodeCgi([self valueFor:"publication_id"]);
}

- (CPArray)topics
{
  if ( !PublicationTopicArray ) {
    PublicationTopicArray = [CPArray arrayWithArray:decodeCgi([self valueFor:"topics"]).split(",")];
    //PublicationTopicArray = [CPArray arrayWithArray:"one,two,three".split(",")];
  }
  return PublicationTopicArray;
}

- (int)dpi
{
  return parseInt(decodeCgi([self valueFor:"dpi"]));
}

- (CPObject) toolBoxItems
{
  // BTW always have an even number of tools, this makes the tool box look better
  return [
          '{ "id": "1", "name" : "Text",         "klazz" : "TextTE" }',
          '{ "id": "3", "name" : "Image",        "klazz" : "ImageTE" }',
          '{ "id": "5", "name" : "FB Like",      "klazz" : "FbLikeTE" }',
          '{ "id": "6", "name" : "Twitter Feed", "klazz" : "TwitterFeedTE" }',
          '{ "id": "7", "name" : "Digg",         "klazz" : "DiggButtonTE" }',
          '{ "id": "4", "name" : "Link",         "klazz" : "LinkTE" }',
          '{ "id": "2", "name" : "Moustache",    "klazz" : "MoustacheTE" }',
          '{ "id": "8", "name" : "Coming Soon",  "klazz" : "ToolElement" }', // TODO
          '{ "id": "9", "name" : "Coming Soon",  "klazz" : "ToolElement" }', // TODO
          '{ "id": "10", "name" : "Coming Soon", "klazz" : "ToolElement" }', // TODO
          '{ "id": "11", "name" : "Coming Soon", "klazz" : "ToolElement" }', // TODO
          '{ "id": "12", "name" : "Coming Soon", "klazz" : "ToolElement" }', // TODO
          '{ "id": "13", "name" : "Coming Soon", "klazz" : "ToolElement" }', // TODO
          '{ "id": "14", "name" : "Coming Soon", "klazz" : "ToolElement" }', // TODO
         ];
}

- (CPObject) pagesPlaceholders
{
  // Note these are in reverse order to as they appear.
  return  [
           '{ "page" : { "number": "4", "name" : "Page" }}',
           '{ "page" : { "number": "3", "name" : "Page" }}',
           '{ "page" : { "number": "2", "name" : "Page" }}',
           '{ "page" : { "number": "1", "name" : "Page" }}',
           ];
}

@end
