
@import <Foundation/CPObject.j>

@implementation Facebook : PageElement
{
  CPImage     _image;
  CPImageView _imgView;
  CPTextField _refView;
}

//
// Class method for creating an array of Flickr objects from JSON
//
+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PageElement generateObjectsFromJson:someJSONObjects forClass:self];
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
  }
  return self;
}

- (CPString)thumbImageUrl
{
  return _json.picture;
}

- (CPString)largeImageUrl
{
  return _json.source;
}

- (CPString) fromUser
{
  return _json.from.name;
}

- (CPString) id_str
{
  return (""+_json.id);
}

- (void)imageDidLoad:(CPImage)anImage
{
  [_imgView setImage:anImage];
}

- (void)generateViewForDocument:(CPView)container
{
  if (!_mainView) {
    _refView = [[CPTextField alloc] initWithFrame:CGRectInset([container bounds], 4, 4)];
    [_imgView setAutoresizingMask:(CPViewMinXMargin | CPViewMaxXMargin)];
    [_refView setFont:[CPFont systemFontOfSize:10.0]];
    [_refView setTextColor:[CPColor blueColor]];
    [_refView setTextShadowColor:[CPColor whiteColor]];

    _imgView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
    [_imgView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [_imgView setImageScaling:CPScaleProportionally];
    [_imgView setHasShadow:YES];

    _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
    [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
    [_mainView addSubview:_imgView];
    [_mainView addSubview:_refView];

    [_refView setFrameOrigin:CGPointMake(45,5)];
    [_imgView setFrameOrigin:CGPointMake(0,15)];

    [self setLocation:[container frame]];
    [self addToServer];
  }

  [container addSubview:_mainView];
  [_refView setStringValue:[self fromUser]];
    
  if ( _image ) {
    [_image setDelegate:nil];
  }

  _image = [[CPImage alloc] initWithContentsOfFile:[self largeImageUrl]];
  [_image setDelegate:self];
  if ([_image loadStatus] != CPImageLoadStatusCompleted) {
    [_imgView setImage:[[PlaceholderManager sharedInstance] spinner]];
  }
}

@end
