@implementation ImageTE : ToolElement
{
  CPImageView _imgView;

  CPString _urlString;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    _urlString = _json.pic_url;
  }
  return self;
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !_urlString ) {
    // Ignore the value of the urlString, if it's not an image or something else (i.e. 
    // cancel) then a spinner will be shown. This can then be removed from the document.
    _urlString = prompt("Enter the URL of the image");
    if ( !_urlString ) {
      _urlString = [PlaceholderManager placeholderImageUrl];
    }
  }

  if (_mainView) {
    [_mainView removeFromSuperview];
  }
  
  _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleToFit];
  [_mainView setHasShadow:YES];

  [container addSubview:_mainView];

  var image = [[CPImage alloc] initWithContentsOfFile:_urlString];
  [image setDelegate:self];

  if ([image loadStatus] != CPImageLoadStatusCompleted) {
    [_mainView setImage:[[PlaceholderManager sharedInstance] spinner]];
  }
}

- (void)imageDidLoad:(CPImage)anImage
{
  [_mainView setImage:anImage];
  initialSize = [anImage size];
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolImage];
}

@end
