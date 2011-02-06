@import <Foundation/CPObject.j>
@import <LPKit/LPURLPostRequest.j>

//
// The workers for the communication manager. This basically listens for responses and
// passes these on to the object that initiated the conection.
//

//////////////////////////////////////////////////////
// Base worker that basically does a classic GET Request, passing back a JSObject to the
// delegate via the selector.
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
  //CPLogConsole(data, "didRecieveData", "[COM WORK]");
  if ( _delegate && _selector && data != "") {
    [_delegate performSelector:_selector withObject:[data objectFromJSON]];
  }
}

- (void)connection:(CPURLConnection)aConnection didFailWithError:(CPString)error
{
  CPLogConsole("[COMM MGR WORKER] ERROR: For " +_urlStr + ", Got Error: " + error);
}

@end

//////////////////////////////////////////////////////
// Handle a request but sending a Post with object data.
// This makes use of LPKit, specifically using the LPURLPostRequest class.
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
  return [super initWithUrl:aUrlString delegate:dataObj 
                   selector:@selector(requestCompleted:)];
}

- (void)generateRequest
{
  var request = [LPURLPostRequest requestWithURL:_urlStr];
  [request setContent:_delegate];
  [CPURLConnection connectionWithRequest:request delegate:self];
}

@end

//////////////////////////////////////////////////////
// Handle a delete operation.
//
@implementation PMCMWdeleteAction : PMCMWwithObject
{
}

+ (id) workerWithUrl:(CPString)urlString delegate:(id)aDelegate selector:(SEL)aSelector
{
  return [[PMCMWdeleteAction alloc] initWithUrl:urlString
                                       delegate:aDelegate
                                       selector:aSelector];
}

+ (id) initWithObject:(CPObject)dataObj urlString:(CPString)aUrlString
{
  return [[PMCMWdeleteAction alloc] initWithObject:dataObj urlString:aUrlString];
}

- (void)generateRequest
{
  var request = [CPURLRequest requestWithURL:_urlStr];
  [request setHTTPMethod:@"DELETE"];
  [CPURLConnection connectionWithRequest:request delegate:self];
}
@end

//////////////////////////////////////////////////////
// Handle an update operation.
//
@implementation PMCMWputAction : PMCMWdeleteAction
{
}

+ (id) initWithObject:(CPObject)dataObj urlString:(CPString)aUrlString
{
  return [[PMCMWputAction alloc] initWithObject:dataObj urlString:aUrlString];
}

- (void)generateRequest
{
  var request = [LPURLPostRequest requestWithURL:_urlStr];
  [request setHTTPMethod:@"PUT"];
  [request setContent:_delegate];
  [CPURLConnection connectionWithRequest:request delegate:self];
}
@end

//////////////////////////////////////////////////////
// This worker does a JSONP request, passing back the data to the desired selector and
// delegate.
//
@implementation PMCMWjsonpWorker : CPObject 
{
  CPString _urlStr;
  id       _delegate;
  SEL      _selector;
}

+ (PMCMWjsonpWorker) workerWithUrl:(CPString)url delegate:(id)aDelegate selector:(SEL)aSelector
{
  return [[PMCMWjsonpWorker alloc] initWithUrl:url 
                                      delegate:aDelegate 
                                      selector:aSelector
                                      callback:@"callback"];
}

+ (PMCMWjsonpWorker) workerWithUrl:(CPString)url 
                          delegate:(id)aDelegate 
                          selector:(SEL)aSelector
                          callback:(CPString)aCallback
{
  return [[PMCMWjsonpWorker alloc] initWithUrl:url 
                                      delegate:aDelegate 
                                      selector:aSelector
                                      callback:aCallback];
}

- (id) initWithUrl:(CPString)url 
          delegate:(id)aDelegate 
          selector:(SEL)aSelector
          callback:(CPString)aCallback
{
  _urlStr = url;
  _delegate = aDelegate;
  _selector = aSelector;
  [CPJSONPConnection connectionWithRequest:[CPURLRequest requestWithURL:_urlStr] 
                                  callback:aCallback 
                                  delegate:self];
}

- (void)connection:(CPJSONPConnection)aConnection didReceiveData:(JSObject)data
{
  //CPLogConsole( "[JsonpWorker] Got data: " + data );
  if ( _delegate && _selector && data ) {
    [_delegate performSelector:_selector withObject:data];
  }
}

- (void)connection:(CPJSONPConnection)aConnection didFailWithError:(CPString)error
{
  if ( _delegate && [_delegate respondsToSelector:@selector(jsonpRequestError:)] ) {
    [_delegate performSelector:@selector(jsonpRequestError:) withObject:error];
  }
  alert(error);
}

@end
