/*
  This stores a bunch of placeholders, required at various places in the application.
  Better name would be ImageManager but placeholder, even 15 days into the project, 
  has history!
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
    var imageAry = ["add", "addHigh", "rm", "rmHigh", "flickr_32", "flickr_32_high", 
                         "facebook_32", "facebook_32_high", "youtube_32_high", "pdf_32","quotes",
                         "html_32", "html_32_high", "stumbleupon_32", "digg_32",
                         "twitter_32_high", "twitter_32", "youtube_32", "pdf_32_high",
                         "fblike", "twitter_feed", "digg_button"];
    for ( var idx = 0; idx < imageAry.length; idx++ ) {
      var name = imageAry[idx];
      [_store setObject:[PMGetImageWorker workerFor:@"Resources/" + name + ".png"] 
                 forKey:[name lowercaseString]];
    }
    [_store setObject:[PMGetImageWorker workerFor:@"Resources/spinner.gif"] forKey:@"sp"];
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

/*
 * Remember, imageFor takes the name of an instance method and *not* the key of 
 * an image in the store.
 */
+ (CPImage) imageFor:(CPString)aMethodName
{
  return [[PlaceholderManager sharedInstance] performSelector:aMethodName];
}

//
// Instance methods.
//

- (CPImage)spinner { return [[_store objectForKey:"sp"] image]; }
- (CPImage)quotes { return [[_store objectForKey:"quotes"] image]; }

- (CPImage)add {  return [[_store objectForKey:"add"] image]; }
- (CPImage)addHigh { return [[_store objectForKey:"addhigh"] image]; }

- (CPImage)remove {return [[_store objectForKey:"rm"] image];}
- (CPImage)removeHigh{ return [[_store objectForKey:"rmhigh"] image];}

- (CPImage)flickr { return [[_store objectForKey:"flickr_32"] image]; }
- (CPImage)flickrHigh {  return [[_store objectForKey:"flickr_32_high"] image]; }

- (CPImage)facebook { return [[_store objectForKey:"facebook_32"] image]; }
- (CPImage)facebookHigh {  return [[_store objectForKey:"facebook_32_high"] image]; }

- (CPImage)youtube { return [[_store objectForKey:"youtube_32"] image]; }
- (CPImage)youtubeHigh {  return [[_store objectForKey:"youtube_32_high"] image]; }

- (CPImage)twitter { return [[_store objectForKey:"twitter_32"] image]; }
- (CPImage)twitterHigh {  return [[_store objectForKey:"twitter_32_high"] image]; }

- (CPImage)pdf { return [[_store objectForKey:"pdf_32"] image]; }
- (CPImage)pdfHigh {  return [[_store objectForKey:"pdf_32_high"] image]; }

- (CPImage)html { return [[_store objectForKey:"html_32"] image]; }
- (CPImage)htmlHigh {  return [[_store objectForKey:"html_32_high"] image]; }

- (CPImage)digg { return [[_store objectForKey:"digg_32"] image]; }
- (CPImage)diggHigh {  return [[_store objectForKey:"digg_32"] image]; }

- (CPImage)stumbleupon { return [[_store objectForKey:"stumbleupon_32"] image]; }
- (CPImage)stumbleuponHigh {  return [[_store objectForKey:"stumbleupon_32"] image]; }

- (CPImage)fblike { return [[_store objectForKey:"fblike"] image]; }
- (CPImage)twitterFeed { return [[_store objectForKey:"twitter_feed"] image]; }
- (CPImage)diggButton { return [[_store objectForKey:"digg_button"] image]; }

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
