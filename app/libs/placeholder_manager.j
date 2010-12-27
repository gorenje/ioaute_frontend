/*
  This stores a bunch of placeholders, required at various places in the application.
*/
@import <Foundation/CPObject.j>

var PlaceholderManagerInstance = nil;

@implementation PlaceholderManager : CPObject
{
  CPDictionary _store;

  PMGetImageWorker _waitingOnImage;
  PMGetImageWorker _spinnerImage;
  PMGetImageWorker _quotesImage;
}

- (id)init
{
  self = [super init];
  if (self) {
    _store = [[CPDictionary alloc] init];
    [_store setObject:[PMGetImageWorker workerFor:@"Resources/placeholder.png"] forKey:@"ph"];
    [_store setObject:[PMGetImageWorker workerFor:@"Resources/spinner.gif"] forKey:@"sp"];
    [_store setObject:[PMGetImageWorker workerFor:@"Resources/quotes.png"] forKey:@"qu"];

    [_store setObject:[PMGetImageWorker workerFor:@"Resources/add.png"] forKey:@"ad"];
    [_store setObject:[PMGetImageWorker workerFor:@"Resources/addHigh.png"] forKey:@"adh"];
    [_store setObject:[PMGetImageWorker workerFor:@"Resources/rm.png"] forKey:@"rm"];
    [_store setObject:[PMGetImageWorker workerFor:@"Resources/rmHigh.png"] forKey:@"rmh"];
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

+ (CPImage) imageFor:(CPString)aName
{
  return [[PlaceholderManager sharedInstance] imageFor:aName];
}

//
// Instance methods.
//

- (CPImage) imageFor:(CPImage)aName
{
  return [[_store objectForKey:aName] image];
}

- (CPImage)spinner
{
  return [[_store objectForKey:"sp"] image];
}

- (CPImage)quotes
{
  return [[_store objectForKey:"qu"] image];
}

- (CPImage)waitingOnImage
{
  return [[_store objectForKey:"ph"] image];
}

- (CPImage)add
{
  return [[_store objectForKey:"ad"] image];
}
- (CPImage)addHigh
{
  return [[_store objectForKey:"adh"] image];
}

- (CPImage)remove
{
  return [[_store objectForKey:"rm"] image];
}
- (CPImage)removeHigh
{
  return [[_store objectForKey:"rmh"] image];
}

@end

@implementation PMGetImageWorker : CPObject 
{
  CPImage image @accessors;
  CPString path @accessors;
}

+ (PMGetImageWorker)workerFor:(CPString)pathStr
{
  return [[PMGetImageWorker alloc] initWithPath:pathStr];
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
