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

- (id) initWithObject:(CPObject)dataObj urlString:(CPString)aUrlString
{
  return [self initWithUrl:aUrlString 
                   delegate:dataObj 
                   selector:@selector(requestCompleted:)];
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
@implementation PMCMWpostAction : PMCommMgrWorker

+ (id) initWithObject:(CPObject)dataObj urlString:(CPString)aUrlString
{
  return [[PMCMWpostAction alloc] initWithObject:dataObj urlString:aUrlString];
}

- (void)generateRequest
{
  var request = [LPURLPostRequest requestWithURL:_urlStr];
  [request setContent:_delegate];
  [CPURLConnection connectionWithRequest:request delegate:self];
}

@end

//////////////////////////////////////////////////////
// Handle a get operation.
//
@implementation PMCMWgetAction : PMCommMgrWorker

+ (id) initWithObject:(CPObject)dataObj urlString:(CPString)aUrlString
{
  return [[PMCMWgetAction alloc] initWithObject:dataObj urlString:aUrlString];
}

- (void)generateRequest
{
  [CPURLConnection 
    connectionWithRequest:[CPURLRequest requestWithURL:_urlStr] 
                 delegate:self];
}
@end



//////////////////////////////////////////////////////
// Handle a delete operation.
//
@implementation PMCMWdeleteAction : PMCommMgrWorker

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
@implementation PMCMWputAction : PMCommMgrWorker

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
