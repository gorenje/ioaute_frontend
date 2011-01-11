/*
 * Store all the colors and sides centrally here.
 */
var ThemeManagerInstance = nil;

var SideBarWidthKey = @"SideBarWidth",
  BgClrContentKey = @"BgClrContent",
  BgToolViewKey = @"BgToolView",
  BgClrPageCtrlKey = @"BgClrPageCtrl",
  BgPageViewKey = @"BgPageView";

@implementation ThemeManager : CPObject
{
  CPDictionary _themeStore;
}

- (id)init
{
  self = [super init];
  if (self) {
    _themeStore = [[CPDictionary alloc] init];
    [_themeStore setObject:@"250" forKey:SideBarWidthKey];
    [_themeStore setObject:[CPColor colorWithHexString:@"e7eff6"] forKey:BgClrContentKey];
    [_themeStore setObject:[CPColor colorWithHexString:@"c2ecc5"] forKey:BgClrPageCtrlKey];
    [_themeStore setObject:[CPColor whiteColor] forKey:BgToolViewKey];
    [_themeStore setObject:[CPColor whiteColor] forKey:BgPageViewKey];
    CPLogConsole( "[TM] initialized the theme manager instance: " + [_themeStore allKeys]);
  }
  return self;
}

+ (ThemeManager) sharedInstance 
{
  if ( !ThemeManagerInstance ) {
    ThemeManagerInstance = [[ThemeManager alloc] init];
  }
  return ThemeManagerInstance;
}

- (CPDictionary)store
{
  return _themeStore;
}

+ (CPObject)valueFor:(CPObject)keyname
{
  CPLogConsole( "Value for : " + keyname );
  return [[[ThemeManager sharedInstance] store] objectForKey:keyname];
}

+ (int)sideBarWidth
{
  return parseInt([ThemeManager valueFor:SideBarWidthKey]);
}

+ (CPColor) bgColorPageListView
{
  return [ThemeManager valueFor:BgPageViewKey];
}

+ (CPColor) bgColorToolView
{
  return [ThemeManager valueFor:BgToolViewKey];
}

+ (CPColor) bgColorContentView
{
  return [ThemeManager valueFor:BgClrContentKey];
}

+ (CPColor) bgColorPageCtrlView
{
  return [ThemeManager valueFor:BgClrPageCtrlKey];
}
