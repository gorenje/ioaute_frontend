@implementation SeekToDropdownHelpers : MixinHelper

- (void)addValuesToPopUpStartAt:(int)aStart endAt:(int)anEnd toPopUp:(id)aPopUp
{
  [aPopUp removeAllItems];
  for(var idx = aStart; idx < anEnd; idx++) {
    var menuItem = [[CPMenuItem alloc] 
                     initWithTitle:[CPString stringWithFormat:"%02d", idx]
                            action:NULL 
                     keyEquivalent:nil];
    [aPopUp addItem:menuItem];
  }
}

/*!
 * We assume that the popups are indexed as follows:
 *  0 ==> hour value - 0 to 24
 *  1 ==> minute value - 0 to 59
 *  2 ==> seconds value - 0 to 59
 */
- (void)setSeekToPopUpValues:(CPArray)popUps
{
  [self addValuesToPopUpStartAt:0 endAt:25 toPopUp:popUps[0]];
  [self addValuesToPopUpStartAt:0 endAt:60 toPopUp:popUps[1]];
  [self addValuesToPopUpStartAt:0 endAt:60 toPopUp:popUps[2]];
}
  
/*!
 * We assume that the popups are indexed as follows:
 *  0 ==> hour value
 *  1 ==> minute value
 *  2 ==> seconds value
 */
- (void)setPopUpsWithTime:(int)aSecondsValue popUps:(CPArray)aPopUpList
{
  var popUpValues = [self obtainHourMinSecs:aSecondsValue];
  for ( var idx = 0; idx < 3; idx++ ) {
    [aPopUpList[idx] selectItemWithTitle:[CPString stringWithFormat:"%02d", 
                                                   popUpValues[idx]]];
  }
}

/*!
  Return an array with values placed at the following index values:
    2 ==> seconds
    1 ==> minutes
    0 ==> hours
*/
- (CPArray)obtainHourMinSecs:(int)aSecValue
{
  var ary = [];
  ary[2] = aSecValue % 60;
  ary[1] = (aSecValue / 60) % 60;
  ary[0] = (aSecValue / 3600) % 25;
  return ary;
}

/*!
 * We assume that the popups are indexed as follows:
 *  0 ==> hour value
 *  1 ==> minute value
 *  2 ==> seconds value
 */
- (int)obtainSeconds:(CPArray)aPopUps
{
  return ( ([[[aPopUps[0] selectedItem] title] intValue] * 3600) +
           ([[[aPopUps[1] selectedItem] title] intValue] * 60) +
            [[[aPopUps[2] selectedItem] title] intValue] );
}

- (CPArray)findPopUpsWithTags:(CPArray)tagValues inViews:(CPArray)subviewsToCheck
{
  var ary = [CPArray arrayWithArray:tagValues];
  var cnt = [subviewsToCheck count];
  for ( var idx = 0; idx < cnt; idx++ ) {
    if ( [subviewsToCheck[idx] isKindOfClass:CPPopUpButton] ) {
      var jdx = [ary indexOfObject:[subviewsToCheck[idx] tag]];
      if ( jdx != CPNotFound ) {
        [ary replaceObjectAtIndex:jdx withObject:subviewsToCheck[idx]];
      }
    }
  }
  return ary;
}

@end
