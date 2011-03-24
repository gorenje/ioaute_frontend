/*
 * Created by Gerrit Riessen
 * Copyright 2010-2011, Gerrit Riessen
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <http://www.gnu.org/licenses/>.
 */
/*
 * Store all the colors and sides centrally here.
 * TODO make a proper theme, for more info:
 * TODO   http://www.annema.me/blog/post/cappuccino-custom-themes
 */
var ThemeManagerInstance = nil;

var SideBarWidthKey      = @"SideBarWidth",
  BgClrContentKey        = @"BgClrContent",
  BgToolViewKey          = @"BgToolView",
  BgClrPageCtrlKey       = @"BgClrPageCtrl",
  BorderColorKey         = @"BorderColor",
  BorderColorToolCellKey = @"BorderColorToolCell",
  ToolHighlightColorKey  = @"ToolHighlightColor",
  BgPageViewKey          = @"BgPageView",
  EditorHighlightKey     = @"EditorHighlightKey";

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
                                 [CPColor colorWithHexString:@"f5f5f5"], ToolHighlightColorKey,
                                 [CPColor grayColor], BorderColorKey,
                                 [CPColor colorWithHexString:@"0f0"], EditorHighlightKey];
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

+ (int)sideBarWidth { return [[ThemeManager valueFor:SideBarWidthKey] intValue]; }
+ (CPColor) bgColorPageListView { return [ThemeManager valueFor:BgPageViewKey]; }
+ (CPColor) bgColorToolView { return [ThemeManager valueFor:BgToolViewKey]; }
+ (CPColor) bgColorContentView { return [ThemeManager valueFor:BgClrContentKey]; }
+ (CPColor) bgColorPageCtrlView { return [ThemeManager valueFor:BgClrPageCtrlKey]; }
+ (CPColor) borderColorToolCell { return [ThemeManager valueFor:BorderColorToolCellKey]; }
+ (CPColor) borderColor { return [ThemeManager valueFor:BorderColorKey]; }
+ (CPColor) toolHighlightColor { return [ThemeManager valueFor:ToolHighlightColorKey]; }
+ (CPColor) editorBgColor { return [ThemeManager valueFor:EditorHighlightKey]; }

@end
