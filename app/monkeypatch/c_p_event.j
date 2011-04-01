@implementation CPEvent (KeyModifierHelpers)

- (BOOL)isShiftDown
{
  return ( ([self modifierFlags] & CPShiftKeyMask) == CPShiftKeyMask);
}

@end
