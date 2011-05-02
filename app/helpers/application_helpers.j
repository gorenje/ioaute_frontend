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

/*!
  Handle two forms of YouTube url:
   http://www.youtube.com/v/4Z9WVZddH9w?f=videos&app=youtube_gdata
   http://www.youtube.com/watch?v=4Z9WVZddH9w&feature=player_embedded
  The first is returned by the API and the second is usually used on the website.
*/
function getVideoIdFromYouTubeUrl(urlString) {
  var v = getVideoIdFromYouTubeWebUrl(urlString);
  return ( v ? v : getVideoIdFromYouTubeApiUrl(urlString) );
}

function getVideoIdFromYouTubeApiUrl(urlString) {
  var pathParts = (urlString.split("?")[0]).split("/");
  // http://www.youtube.com/v/4Z9WVZddH9w becomes
  //    ["http:", "", "www.youtube.com", "v", "4Z9WVZddH9w"]
  if ( pathParts && pathParts.length > 4 ) {
    return pathParts[pathParts.length - 1];
  } else {
    return nil;
  }
}

function getVideoIdFromYouTubeWebUrl(urlString) {
  var queryString = queryStringFromUrl(urlString);
  if ( queryString ) {
    var store = getQueryVariables(queryString);
    return [store objectForKey:@"v"];
  } else {
    return nil;
  }
}

function decodeCgi(str) {
  // this assumes that '+' is a space. unescape only seems to unescape %xy escapes.
  return unescape(str.replace(/\+/g, " "));
}

function rectToString(rect) {
  return ("[Origin.x: " + rect.origin.x + " y: " + rect.origin.y + " width: " +
          rect.size.width + " height: " + rect.size.height + "]");
}

function is_undefined(value) {
  return ( typeof( value ) == "undefined" );
}

function is_defined(value) {
  return ( typeof( value ) != "undefined" );
}

function check_for_undefined( value, default_value ) {
  return ( typeof( value ) == "undefined" ? default_value : value );
}

/*
  OPEN_LINK is taken from
     https://github.com/Me1000/CappuTweetie/blob/master/Controllers/AppController.j
*/
OPEN_LINK = function(url)
{
  //is it an image?
  var imageTypes = ["jpg", "gif", "png"],
  isImage = [imageTypes containsObject:[url pathExtension]];

  if (isImage)
  {
    var mouseAt = [[CPApp currentEvent] globalLocation],
      location = CGRectMake(mouseAt.x, mouseAt.y, 25, 25),
      imageWindow = [[CPWindow alloc] initWithContentRect:location styleMask:CPTitledWindowMask|CPHUDBackgroundWindowMask|CPResizableWindowMask|CPClosableWindowMask],
      contentView = [imageWindow contentView],
      imageView = [[CPImageView alloc] initWithFrame:[contentView bounds]],
      finalFrame = CGRectMake(300,100, 500, 500);

    [imageView setImage:[[CPImage alloc] initWithContentsOfFile:url]];
    [imageView setImageScaling:CPScaleProportionally];
    [imageView setAutoresizingMask:CPViewHeightSizable|CPViewWidthSizable];

    [contentView addSubview:imageView];
    [imageWindow orderFront:self];
    [imageWindow setFrame:finalFrame display:YES animate:YES];
    return;
  }

  if ([CPPlatform isBrowser])
    window.open(url);
  else
    window.location = url;
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
  switch ( returnCode ) {
  case 0: // Restart
    window.location.reload();
    break;
  }
}

@end

@implementation PageReorderRequestHelper : CPObject
{
  CPArray list;
  id m_delegate;
  SEL m_selector;
}

- (id)initWithPages:(CPArray)pages
           delegate:(id)aDelegate
           selector:(SEL)aSelector
{
  self = [super init];
  if ( self ) {
    m_delegate = aDelegate;
    m_selector = aSelector;
    list = [];
    for ( var idx = 0; idx < [pages count]; idx++ ) {
      list.push( [ [pages[idx] pageIdx], [pages[idx] number]] );
    }
  }
  return self;
}

- (void)requestCompleted:(CPObject)data
{
  [m_delegate performSelector:m_selector withObject:data];
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

@implementation TNToolTip (WithTimer)

+ (TNToolTip)toolTipWithString:(CPString)aString
                       forView:(CPView)aView
                    closeAfter:(float)aSecondsValue
{
  var tooltip = [TNToolTip toolTipWithString:aString forView:aView];

  var stopInvoker = [[CPInvocation alloc] initWithMethodSignature:nil];
  [stopInvoker setTarget:tooltip];
  [stopInvoker setSelector:@selector(fadeOut)];
  [CPTimer scheduledTimerWithTimeInterval:aSecondsValue
                               invocation:stopInvoker
                                  repeats:NO];

  if ( ![[[ConfigurationManager sharedInstance] pubProperties] showToolTips] ) {
    [tooltip close];
  }
  return tooltip;
}

- (void)fadeOut
{
  var thisDict = [CPDictionary dictionaryWithObjects:[self, CPViewAnimationFadeOutEffect]
                                             forKeys:[CPViewAnimationTargetKey,
                                                      CPViewAnimationEffectKey]];
  var animation = [[CPViewAnimation alloc] initWithViewAnimations:[thisDict]];
  [animation setDuration:1.0];
  [animation setDelegate:self];
  [animation startAnimation];
}

- (void)animationDidEnd:(id)sender
{
  [self close];
}

@end
