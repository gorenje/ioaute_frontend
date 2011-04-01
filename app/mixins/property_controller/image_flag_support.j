@implementation PropertyControllerImageFlagSupport : GRClassMixin

- (CPAction)changeImageFlag:(id)sender
{
  if ( [sender state] == CPOffState ) {
    [m_pageElement removeImageFlag:[sender tag]];
  } else {
    [m_pageElement addImageFlag:[sender tag]];
  }
}

- (void)setupFlagFields:(CPArray)subviewsToCheck
{
  var cnt = [subviewsToCheck count],
    image_flag_value = [m_pageElement imageFlags];
  for ( var idx = 0; idx < cnt; idx++ ) {
    if ( [subviewsToCheck[idx] isKindOfClass:CPCheckBox] && [subviewsToCheck[idx] tag] > 0) {
      if ( (image_flag_value & [[subviewsToCheck[idx] tag]]) > 0 ) {
        [subviewsToCheck[idx] setState:CPOnState];
      } else {
        [subviewsToCheck[idx] setState:CPOffState];
      }
    }
  }
}

@end
