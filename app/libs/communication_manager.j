/*
  Communication manager only communicates with the server that is hosting this applicatoin.
  It's responsible for sending back information about element movements and resizing
  so that the server knows where the individual elements are.
*/
@import <Foundation/CPObject.j>
@import <LPKit/LPURLPostRequest.j>

var CommunicationManagerInstance = nil;

@implementation CommunicationManager : CPObject
{
}

- (id)init
{
  self = [super init];
  if (self) {
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

//
// Methods dealing with PageElement
//
- (CPString)basePageElementUrl
{
  return [CPString stringWithFormat:@"%s/%s/pages/%s/page_elements", 
                   [[ConfigurationManager sharedInstance] server],
                   [[ConfigurationManager sharedInstance] publication_id], 
                   [[ConfigurationManager sharedInstance] pageNumber]];
}

-(void)resizeElement:(PMDataSource)obj
{
  var url = [CPString stringWithFormat:@"%s/%d/resize.json", [self basePageElementUrl],
                      [obj pageElementId]];
  CPLogConsole("[RESIZEELEM] URL CONSTRUCTED: " + url);
  [PMCMWwithObject initWithObject:obj urlString:url];
}

- (void)addElement:(PMDataSource)obj
{
  var url = [CPString stringWithFormat:@"%s.json", [self basePageElementUrl]];
  CPLogConsole("[ADDELEM] URL CONSTRUCTED: " + url);
  [PMCMWwithObject initWithObject:obj urlString:url];
}

- (void)deleteElement:(PMDataSource)obj
{
  var url = [CPString stringWithFormat:@"%s/%d.json", [self basePageElementUrl],
                      [obj pageElementId]];
  CPLogConsole("[DELELEM] URL CONSTRUCTED: " + url);
  [PMCMWdeleteAction initWithObject:obj urlString:url];
}

//
// Adminstration of the connection to the server.
//
- (void)ping
{
  var url = [CPString stringWithFormat:@"%s/ping.json",
                      [[ConfigurationManager sharedInstance] server]];
  [PMCommMgrWorker workerWithUrl:url delegate:self selector:@selector(pingResponse:)];
}

- (void)pingResponse:(JSObject)data
{
  CPLogConsole("[PING] response: " + data.error);
}

@end

//
// The worker for the communication manager. This basically listens for responses and
// passes these on to the object that initiated the conection.
//
@implementation PMCommMgrWorker : CPObject 
{
  CPString _urlStr;
  id       _delegate;
  SEL      _selector;
}

+ (id) workerWithUrl:(CPString)urlString delegate:(id)aDelegate selector:(SEL)aSelector
{
  return [[PMCommMgrWorker alloc] initWithUrl:urlString
                                     delegate:aDelegate
                                     selector:aSelector];
}

- (id)initWithUrl:(CPString)urlString delegate:(id)aDelegate selector:(SEL)aSelector
{
  self = [super init];
  if ( self ) {
    _urlStr   = urlString;
    _delegate = aDelegate;
    _selector = aSelector;
    [self generateRequest];
  }
  return self;
}

- (void)generateRequest
{
  var request = [CPURLRequest requestWithURL:_urlStr];
  [CPURLConnection connectionWithRequest:request delegate:self];
}

- (void)connection:(CPURLConnection)aConnection didReceiveData:(CPString)data
{
  // TODO be a little clever when the server does not exist, ie connection refused
  // TODO errors aren't passed to didFailWithError, rather they are dumpped here
  // TODO with an empty (i.e. "") data string... But that could also mean that
  // TODO the server returned nothing. So we need to ensure that the server *always*
  // TODO returns some data ...
  CPLogConsole(data, "didRecieveData", "[COM WORK]");
  if ( _delegate && _selector && data != "") {
    [_delegate performSelector:_selector withObject:[data objectFromJSON]];
  }
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPString)error
{
  CPLogConsole("[COMM MGR WORKER] ERROR: For " +_urlStr + ", Got Error: " + error);
}

@end

//
// Handle a request but sending a Post with object data.
//
@implementation PMCMWwithObject : PMCommMgrWorker
{
}

+ (id) initWithObject:(CPObject)dataObj urlString:(CPString)aUrlString
{
  return [[PMCMWwithObject alloc] initWithObject:dataObj urlString:aUrlString];
}

- (id) initWithObject:(CPObject)dataObj urlString:(CPString)aUrlString
{
  return [super initWithUrl:aUrlString delegate:dataObj selector:@selector(requestCompleted:)];
}

- (void)generateRequest
{
  var request = [LPURLPostRequest requestWithURL:_urlStr];
  [request setContent:_delegate];
  [CPURLConnection connectionWithRequest:request delegate:self];
}

@end

//
// Handle a delete operation.
//
@implementation PMCMWdeleteAction : PMCommMgrWorker
{
}

+ (id) initWithObject:(CPObject)dataObj urlString:(CPString)aUrlString
{
  return [[PMCMWwithObject alloc] initWithObject:dataObj urlString:aUrlString];
}

- (id) initWithObject:(CPObject)dataObj urlString:(CPString)aUrlString
{
  return [super initWithUrl:aUrlString delegate:dataObj selector:@selector(requestCompleted:)];
}

- (void)generateRequest
{
  var request = [LPURLPostRequest requestWithURL:_urlStr];
  [request setContent:_delegate];
  [request setHTTPMethod:@"DELETE"];
  [CPURLConnection connectionWithRequest:request delegate:self];
}

@end
