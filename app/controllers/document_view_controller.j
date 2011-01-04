/*
 * Controller for managing the document view which is our publication or 
 * rather one page of that publication.
 */
@import <Foundation/CPObject.j>

var DocumentViewControllerInstance = nil;

@implementation DocumentViewController : CPObject
{
  DocumentView _documentView;
}

- (id)init
{
  self = [super init];
  if (self) {
  }
  return self;
}

+ (DocumentViewController) sharedInstance 
{
  if ( !DocumentViewControllerInstance ) {
    DocumentViewControllerInstance = [[DocumentViewController alloc] init];
  }
  return DocumentViewControllerInstance;
}

- (DocumentView) createDocumentView:(CGRect)aRect
{
  _documentView = [[DocumentView alloc] initWithFrame:aRect];
  // [_documentView setDelegate:self];
  return _documentView;
}
@end
