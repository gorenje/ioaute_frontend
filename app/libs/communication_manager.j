/*
  Communication manager only communicates with the server that is hosting this application.
  It's responsible for sending back information about element movements and resizing
  so that the server knows where the individual elements are.

  The CommunicationManager, as with all good managers, has a bunch of workers that do the
  hard lifting. In this case, there are workers for delete, post and get operations. Also
  workers are available for JSONP requests. So that all this thing does, is create a worker,
  giving it the correct object and callback once the request comes back and that's it. It
  doesn't even maintain a list of currently running workers (although this will be necessary
  for undo/redo and back communication channels -- but we're working in an ideal internet
  world).
*/
@import <Foundation/CPObject.j>

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
    CPLogConsole("[COMMGR] booting singleton instance");
    CommunicationManagerInstance = [[CommunicationManager alloc] init];
  }
  return CommunicationManagerInstance;
}

//
// Methods dealing with PageElement
//
- (CPString)basePageElementUrl
{
  return [CPString stringWithFormat:@"%s/%s/pages/%s/page_elements", 
                   [[ConfigurationManager sharedInstance] server],
                   [[ConfigurationManager sharedInstance] publication_id], 
                   [[PageViewController sharedInstance] pageNumber]];
}

-(void)resizeElement:(PageElement)obj
{
  var url = [CPString stringWithFormat:@"%s/%d/resize.json", [self basePageElementUrl],
                      [obj pageElementId]];
  CPLogConsole("[RESIZEELEM] URL CONSTRUCTED: " + url);
  [PMCMWwithObject initWithObject:obj urlString:url];
}

- (void)addElement:(PageElement)obj
{
  var url = [CPString stringWithFormat:@"%s.json", [self basePageElementUrl]];
  CPLogConsole("[ADDELEM] URL CONSTRUCTED: " + url);
  [PMCMWwithObject initWithObject:obj urlString:url];
}

- (void)deleteElement:(PageElement)obj
{
  var url = [CPString stringWithFormat:@"%s/%d.json", [self basePageElementUrl],
                      [obj pageElementId]];
  CPLogConsole("[DELELEM] URL CONSTRUCTED: " + url);
  [PMCMWdeleteAction initWithObject:obj urlString:url];
}

- (void)updateElement:(PageElement)obj
{
  var url = [CPString stringWithFormat:@"%s/%d.json", [self basePageElementUrl],
                      [obj pageElementId]];
  CPLogConsole("[UPDELEM] URL CONSTRUCTED: " + url);
  [PMCMWputAction initWithObject:obj urlString:url];
}

//
// Page management.
//
- (void)pagesForPublication:(id)aDelegate selector:(SEL)aSelector
{
  var url = [CPString stringWithFormat:@"%s/%s/pages.json", 
                      [[ConfigurationManager sharedInstance] server],
                      [[ConfigurationManager sharedInstance] publication_id]];
  [PMCommMgrWorker workerWithUrl:url delegate:aDelegate selector:aSelector];
}

- (void)newPageForPublication:(CPString)pageName delegate:(id)aDelegate selector:(SEL)aSelector
{
  var url = [CPString stringWithFormat:@"%s/%s/pages/new.json?name=%s", 
                      [[ConfigurationManager sharedInstance] server],
                      [[ConfigurationManager sharedInstance] publication_id],
                      encodeURIComponent(pageName)];
  [PMCommMgrWorker workerWithUrl:url delegate:aDelegate selector:aSelector];
}

- (void)deletePageForPublication:(Page)page delegate:(id)aDelegate selector:(SEL)aSelector
{
  var url = [CPString stringWithFormat:@"%s/%s/pages/%d.json", 
                      [[ConfigurationManager sharedInstance] server],
                      [[ConfigurationManager sharedInstance] publication_id],
                      [page number]];
  [PMCMWdeleteAction workerWithUrl:url delegate:aDelegate selector:aSelector];
}

- (void)pageElementsForPage:(Page)page delegate:(id)aDelegate selector:(SEL)aSelector
{
  var url = [CPString stringWithFormat:@"%s/%s/pages/%d.json", 
                      [[ConfigurationManager sharedInstance] server],
                      [[ConfigurationManager sharedInstance] publication_id],
                      [page number]];
  [PMCommMgrWorker workerWithUrl:url delegate:aDelegate selector:aSelector];
}

//
// Publication management.
//
- (void)publishWithDelegate:(id)aDelegate selector:(SEL)aSelector 
{
  var url = [CPString stringWithFormat:@"%s/%s/publish.json?pub_format=pdf", 
                      [[ConfigurationManager sharedInstance] server],
                      [[ConfigurationManager sharedInstance] publication_id]];
  [PMCommMgrWorker workerWithUrl:url delegate:aDelegate selector:aSelector];
}

- (void)publishInHtmlWithDelegate:(id)aDelegate selector:(SEL)aSelector 
{
  var url = [CPString stringWithFormat:@"%s/%s/publish.json?pub_format=html", 
                      [[ConfigurationManager sharedInstance] server],
                      [[ConfigurationManager sharedInstance] publication_id]];
  [PMCommMgrWorker workerWithUrl:url delegate:aDelegate selector:aSelector];
}

//
// Adminstration of the connection to the server.
//
- (void)ping:(id)aDelegate selector:(SEL)aSelector 
{
  var url = [CPString stringWithFormat:@"%s/ping.json",
                      [[ConfigurationManager sharedInstance] server]];
  [PMCommMgrWorker workerWithUrl:url delegate:aDelegate selector:aSelector];
}

@end

