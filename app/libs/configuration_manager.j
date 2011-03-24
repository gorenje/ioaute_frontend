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
  CPString     m_facebook_app_id;
  CPString     m_flickr_api_key @accessors(property=flickrApiKey,readonly);
  PubConfig    m_publication_properties @accessors(property=pubProperties);
}

- (id)init
{
  self = [super init];
  if (self) {
    m_facebook_app_id        = @"";
    m_flickr_api_key         = @"";
    m_cookieStore            = [[CPDictionary alloc] init];
    m_publication_properties = [[PubConfig alloc] init];
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
    PublicationTopicArray = 
      [CPArray arrayWithArray:decodeCgi([self valueFor:"topics"]).split(",")];
  }
  return PublicationTopicArray;
}

- (int)dpi
{
  var dpi = parseInt(decodeCgi([self valueFor:"dpi"]),10);
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

+ (CPString)previewUrl
{
  return [CPString stringWithFormat:"%s/%s", 
                   [[ConfigurationManager sharedInstance] server],
                   [[ConfigurationManager sharedInstance] publication_id]];
}

+ (CPString)goingBackUrl
{
  return [CPString stringWithFormat:"%s/user", 
                   [[ConfigurationManager sharedInstance] server]];
}

- (void)publishRequestCompleted:(JSObject)data
{
  switch ( data.action ) {
  case "publications_ping":
    if ( data.status == "ok" ) {
      m_facebook_app_id   = data.data.facebook_app_id;
      m_flickr_api_key    = data.data.flickr_api_key;

      [m_publication_properties setConfig:data.data.publication];

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
                      object:[toolBarButtons, data.data.tool_tips]];
    }
    break;
  }
}
@end

