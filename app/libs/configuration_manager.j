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
  CPDictionary m_cookieStore;
  CPString m_facebook_app_id;
  CPString m_flickr_api_key @accessors(property=flickrApiKey,readonly);
}

- (id)init
{
  self = [super init];
  if (self) {
    m_cookieStore = [[CPDictionary alloc] init];
    m_facebook_app_id = @"";
    m_flickr_api_key = @"";
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

  var val = [m_cookieStore objectForKey:name];
  if ( !val ) {
    var cookie = [[CPCookie alloc] initWithName:name];
    if ( cookie ) {
      val = cookie;
      CPLogConsole( "[CONFIG] Found value '" + [val value] + "' for '" + name + "'");
      [m_cookieStore setObject:cookie forKey:name];
    } else {
      CPLogConsole( "[CONFIG] ERROR No cookie found for '" + name + "'");
    }
  }
  return [val value];
}

- (CPString)fbCookie
{
  var cookie = [self valueFor:"fbs_" + m_facebook_app_id];
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
  }
  return PublicationTopicArray;
}

- (int)dpi
{
  var dpi = parseInt(decodeCgi([self valueFor:"dpi"]));
  if ( isNaN(dpi) ) dpi = 96;
  return dpi;
}

// IMPORTANT: this returns a Portrait sized A4 value, based on the current dpi value.
- (CGSize)getA4Size
{
  /*
   * DIN A4 size in pixels based on dpi (portrait):
   * 210mm = 8.2677165354 in == width
   * 297mm = 11.6929133739 in == height
   */
  var dpi = [self dpi];
  return CGSizeMake(8.2677165354 * dpi, 11.6929133739 * dpi);
}

// IMPORTANT: this returns a Portrait sized Letter value, based on the current dpi value.
- (CGSize)getLetterSize
{
  /*
   * Letter size in pixels based on dpi (portrait):
   * 8.5 in == width
   * 11 in == height
   */
  var dpi = [self dpi];
  return CGSizeMake(8.5 * dpi, 11 * dpi);
}

- (BOOL)is_new
{
  return ([self valueFor:"is_new"] == "yes");
}

- (CPObject) pagesPlaceholders
{
  // Note these are in reverse order to as they appear.
  return  [
           '{ "page" : { "number": "1", "name" : "Page", "id" : 1 }}',
           '{ "page" : { "number": "2", "name" : "Page", "id" : 2 }}',
           '{ "page" : { "number": "3", "name" : "Page", "id" : 3 }}',
           '{ "page" : { "number": "4", "name" : "Page", "id" : 4 }}',
           ];
}

- (void)publishRequestCompleted:(JSObject)data
{
  switch ( data.action ) {
  case "publications_ping":
    if ( data.status == "ok" ) {
      CPLogConsole( "[CONFIG] Ping was ok!" );
      m_facebook_app_id = data.data.facebook_app_id;
      m_flickr_api_key = data.data.flickr_api_key;

      [[CPNotificationCenter defaultCenter]
        postNotificationName:ConfigurationManagerToolBoxArrivedNotification
                      object:data.data.tool_box_items];

      var toolBarButtons = data.data.toolbar_left;
      [toolBarButtons addObjectsFromArray:[CPToolbarFlexibleSpaceItemIdentifier]];
      [toolBarButtons addObjectsFromArray:data.data.toolbar_middle];
      [toolBarButtons addObjectsFromArray:[CPToolbarFlexibleSpaceItemIdentifier]];
      [toolBarButtons addObjectsFromArray:data.data.toolbar_right];
      [[CPNotificationCenter defaultCenter]
        postNotificationName:ConfigurationManagerToolBarArrivedNotification
                      object:toolBarButtons];
    }
    break;
  }
}
@end
