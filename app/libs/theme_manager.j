/*
 * Store all the colors and sides centrally here.
 * TODO make a proper theme, for more info:
 * TODO   http://www.annema.me/blog/post/cappuccino-custom-themes
 */
var ThemeManagerInstance = nil;

var SideBarWidthKey = @"SideBarWidth",
  BgClrContentKey = @"BgClrContent",
  BgToolViewKey = @"BgToolView",
  BgClrPageCtrlKey = @"BgClrPageCtrl",
  BorderColorKey = @"BorderColor",
  BorderColorToolCellKey = @"BorderColorToolCell",
  BgPageViewKey = @"BgPageView";

@implementation ThemeManager : CPObject
{
  CPDictionary _themeStore;
}

- (id)init
{
  self = [super init];
  if (self) {
    _themeStore = [CPDictionary dictionaryWithObjectsAndKeys:@"250", SideBarWidthKey,
                                 [CPColor colorWithHexString:@"e7eff6"], BgClrContentKey,
                                 [CPColor colorWithHexString:@"c2ecc5"], BgClrPageCtrlKey,
                                [CPColor whiteColor], BgToolViewKey,
                                [CPColor whiteColor], BgPageViewKey,
                                [CPColor grayColor], BorderColorToolCellKey,
                                [CPColor grayColor], BorderColorKey];
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
  return [[[ThemeManager sharedInstance] store] objectForKey:keyname];
}

+ (int)sideBarWidth { return parseInt([ThemeManager valueFor:SideBarWidthKey]); }
+ (CPColor) bgColorPageListView { return [ThemeManager valueFor:BgPageViewKey]; }
+ (CPColor) bgColorToolView { return [ThemeManager valueFor:BgToolViewKey]; }
+ (CPColor) bgColorContentView { return [ThemeManager valueFor:BgClrContentKey]; }
+ (CPColor) bgColorPageCtrlView { return [ThemeManager valueFor:BgClrPageCtrlKey]; }
+ (CPColor) borderColorToolCell { return [ThemeManager valueFor:BorderColorToolCellKey]; }
+ (CPColor) borderColor { return [ThemeManager valueFor:BorderColorKey]; }

@end
