@implementation YouTubeVideoProperties : MixinHelper

- (BOOL) hasProperties
{
  return YES;
}

- (void)openProperyWindow
{
  [[[PropertyYouTubeVideoController alloc] 
     initWithWindowCibName:YouTubeVideoPropertyWindowCIB
               pageElement:self] showWindow:self];
}

@end
