/*
  This stores a bunch of placeholders, required at various places in the application.
*/
@import <Foundation/CPObject.j>

var CommunicationManagerInstance = nil;

@implementation CommunicationManager : CPObject
{
  CPURL _baseUrl;
}

- (id)init
{
  self = [super init];
  if (self) {
    _baseUrl = [CPURL URLWithString:[[ConfigurationManager sharedInstance] server]];
  }
  return self;
}

//
// Singleton class, this provides the callee with the only instance of this class.
//
+ (CommunicationManager) sharedInstance 
{
  if ( !CommunicationManagerInstance ) {
    CPLogConsole("[PLM] booting singleton instance");
    CommunicationManagerInstance = [[CommunicationManager alloc] init];
  }
  return CommunicationManagerInstance;
}

//
// Instance methods.
//

- (void)ping
{
  [[PMCommMgrWorker alloc] initWithUrl:[_baseUrl absoluteString] + "/ping.json"];
}

@end

@implementation PMCommMgrWorker : CPObject 
{
  // TODO: bunch of callback information, such as which object and which selector ...
  CPString _urlStr;
}

- (id)initWithUrl:(CPString)urlString
{
  self = [super init];
  if ( self ) {
    _urlStr = urlString;
    var request = [CPURLRequest requestWithURL:urlString];
    //[CPJSONPConnection sendRequest:request callback:"commcallback" delegate:self];
    [CPURLConnection connectionWithRequest:request delegate:self];
  }
  return self;
}

// - (void)connection:(CPJSONPConnection)aConnection didReceiveData:(CPString)data
// {
//   // TODO -- Need to pass on the data
//   CPLogConsole("[COMM MGR WORKER] OK For " + _urlStr);
// }
// - (void)connection:(CPJSONPConnection)aConnection didFailWithError:(CPString)error
// {
//   CPLogConsole("[COMM MGR WORKER] ERROR: For " +_urlStr + ", Got Error: " + error);
// }

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)data
{
  // TODO -- Need to pass the data on
  CPLogConsole("[COMM MGR WORKER] OK For " + _urlStr + " and git data " + [data objectFromJSON].error);
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPString)error
{
  CPLogConsole("[COMM MGR WORKER] ERROR: For " +_urlStr + ", Got Error: " + error);
}

@end
