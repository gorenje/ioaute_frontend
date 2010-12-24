/*
  This stores a bunch of placeholders, required at various places in the application.
*/
@import <Foundation/CPObject.j>

var PlaceholderManagerInstance = nil;

@implementation PlaceholderManager : CPObject
{
  PMGetImageWorker _waitingOnImage;
  PMGetImageWorker _spinnerImage;
}

- (id)init
{
  self = [super init];
  if (self) {
    CPLogConsole("[PLM] getting placeholder image");
    _waitingOnImage = [[PMGetImageWorker alloc] initWithPath:@"Resources/placeholder.png"];

    CPLogConsole("[PLM] getting spinner image");
    _spinnerImage = [[PMGetImageWorker alloc] initWithPath:@"Resources/spinner.gif"];
  }
  return self;
}

//
// Singleton class, this provides the callee with the only instance of this class.
//
+ (PlaceholderManager) sharedInstance 
{
  if ( !PlaceholderManagerInstance ) {
    CPLogConsole("[PLM] booting singleton instance");
    PlaceholderManagerInstance = [[PlaceholderManager alloc] init];
  }
  return PlaceholderManagerInstance;
}

//
// Instance methods.
//

- (CPImage)spinner
{
  return [_spinnerImage image];
}

- (CPImage)waitingOnImage
{
  return [_waitingOnImage image];
}

@end

@implementation PMGetImageWorker : CPObject 
{
  CPImage image @accessors;
  CPString path @accessors;
}

- (id)initWithPath:(CPString)pathStr
{
  self = [super init];
  if (self) {
    path = pathStr;
    CPLogConsole("[PLM] worker retrieving image @ " + path);
    image = [[CPImage alloc] initWithContentsOfFile:path];
    [image setDelegate:self];
  }
  return self;
}

- (void)imageDidLoad:(CPImage)anImage
{
  CPLogConsole("[PLM] worker loaded image: " + anImage);
  image = anImage;
}

@end
