/*!
  State handling to support (limited) undo/redo. Should store the current state
 (i.e. all instance variables) onto the state-stack. The very first one is retrieved
 and the state is restored from that one in the case of a pop. The state container is
 thrown out are restoring the state.

 Could also do this by generating a state hash that can be passed back to reinstate the
 previous state. DesignPattern ....

*/
@implementation ObjectStateSupport : MixinHelper
{
  CPDictionary mtmp_last_good_known_state;
}

- (void)pushState
{
  var stateSelectors = [self stateCreators];
  mtmp_last_good_known_state = [CPDictionary dictionary];
  for ( var idx = 0; idx < [stateSelectors count]; idx += 2 ) {
    [mtmp_last_good_known_state setObject:[self performSelector:stateSelectors[idx]]
                                   forKey:stateSelectors[idx]];
  }
}

- (void)popState
{
  var stateSelectors = [self stateCreators];
  for ( var idx = 0; idx < [stateSelectors count]; idx += 2 ) {
    [self performSelector:stateSelectors[idx+1]
               withObject:[mtmp_last_good_known_state objectForKey:stateSelectors[idx]]];
  }
  [self postStateRestore];
}


@end
