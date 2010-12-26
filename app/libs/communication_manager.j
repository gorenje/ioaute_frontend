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

- (void)addElement:(PMDataSource)obj
{
  var publication_id = [[ConfigurationManager sharedInstance] publication_id];
  var page_num = [[ConfigurationManager sharedInstance] pageNumber];
  var url = [CPString stringWithFormat:@"%s/%s/pages/%s/page_elements.json", [_baseUrl absoluteString], publication_id, page_num];
  CPLogConsole("[ADDELEM] URL CONSTRUCTED: " + url);
  [PMCMWwithObject initWithObject:obj urlString:url];
}

- (void)ping
{
  [PMCommMgrWorker workerWithUrl:([_baseUrl absoluteString] + "/ping.json")
                        delegate:self 
                        selector:@selector(pingResponse:)];
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
  if ( _delegate && _selector ) {
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
