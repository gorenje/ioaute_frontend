/*
  This manages the facebook stuff for us.
*/
@import <Foundation/CPObject.j>

var FacebookManagerInstance = nil;

@implementation FacebookManager : CPObject
{
  CPDictionary _cookieValues;
  CPObject _userNameField;
}

- (id)init
{
  self = [super init];
  if (self) {
    _cookieValues = getQueryVariables([[ConfigurationManager sharedInstance] fbCookie]);
    CPLogConsole("[FB] Access Token: '" + [_cookieValues objectForKey:"access_token"] + "'");
  }
  return self;
}

//
// Singleton class, this provides the callee with the only instance of this class.
//
+ (FacebookManager) sharedInstance 
{
  if ( !FacebookManagerInstance ) {
    FacebookManagerInstance = [[FacebookManager alloc] init];
  }
  return FacebookManagerInstance;
}

//
// Instance methods.
//

- (void)fbUserName:(CPObject)aTextField
{
  _userNameField = aTextField;
  var urlStr = [CPString stringWithFormat:@"https://graph.facebook.com/me?access_token=%s",
                         [_cookieValues objectForKey:"access_token"]];
  [FBRequestWorker workerWithUrl:urlStr delegate:self selector:@selector(fbUpdateUserName:)];
}

- (void)fbUpdateUserName:(JSObject)data
{
  CPLogConsole( "[FB] setting label value: '" + data.name + "'");
  [_userNameField setLabel:data.name];
}

@end

@implementation FBRequestWorker : CPObject 
{
  CPString _urlStr;
  id       _delegate;
  SEL      _selector;
}

+ (FBRequestWorker) workerWithUrl:(CPString)url delegate:(id)aDelegate selector:(SEL)aSelector
{
  return [[FBRequestWorker alloc] initWithUrl:url delegate:aDelegate selector:aSelector];
}

- (id) initWithUrl:(CPString)url delegate:(id)aDelegate selector:(SEL)aSelector
{
  _urlStr = url;
  _delegate = aDelegate;
  _selector = aSelector;
  [CPJSONPConnection connectionWithRequest:[CPURLRequest requestWithURL:_urlStr] 
                                  callback:"callback" delegate:self];
}

- (void)connection:(CPJSONPConnection)aConnection didReceiveData:(JSObject)data
{
  CPLogConsole( "[FBWorker] Got data: " + data );
  if ( _delegate && _selector && data ) {
    [_delegate performSelector:_selector withObject:data];
  }
}

- (void)connection:(CPJSONPConnection)aConnection didFailWithError:(CPString)error
{
  alert(error) ;
}

@end
