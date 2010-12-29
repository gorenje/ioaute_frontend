/*
  Communication manager only communicates with the server that is hosting this applicatoin.
  It's responsible for sending back information about element movements and resizing
  so that the server knows where the individual elements are.
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

