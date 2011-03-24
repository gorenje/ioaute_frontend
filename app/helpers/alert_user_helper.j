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
/*!
  Helper for throwing up various alert windows to alert the user to something.
*/
@implementation AlertUserHelper : CPObject

+ (void)withTodo:(CPString)msg
{
  var alert = [[CPAlert alloc] init];
  [alert setMessageText:msg];
  [alert setTitle:@"Todo"];
  [alert setAlertStyle:CPInformationalAlertStyle];
  [alert addButtonWithTitle:@"OK"];
  [alert runModal];
}

+ (void)withPageElementError:(CPString)msg
{
  var alert = [[CPAlert alloc] init];
  [alert setMessageText:msg];
  [alert setTitle:@"Adding Element Not Possible"];
  [alert setAlertStyle:CPInformationalAlertStyle];
  [alert addButtonWithTitle:@"OK"];
  [alert runModal];
}

+ (void) ofPublicationUrl:(CPString)urlStr hashStr:(CPString)hshStr
{
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

+ (void) ofPublicationPreviewUrl:(CPString)urlStr
{
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

+(void) goingBack:(CPString)urlStr
{
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

+(void) ofCrash
{
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

@end

/*!
  Responsible for helping the AlertUserHelper to open URLs in new tabs.
*/
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
