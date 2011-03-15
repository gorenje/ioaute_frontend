/*!
 Mixin for supporting the retrieval and checking of data from the user. I.e. quickly
 throw up an input window and obtain some information from the user.

 This assumes that the callback promptDataCameAvailable:(CPString)responseValue is defined
 by the class using this mixin.
*/
@implementation PageElementInputSupport : MixinHelper

- (CPString) obtainInput:(CPString)aPrompt defaultValue:(CPString)aDefaultValue
{
  var controller = [PromptWindowController alloc];
  [controller initWithWindowCibName:"PromptWindow"];
  [controller setDefaultValue:aDefaultValue];
  [controller setPrompt:aPrompt];
  [controller setDelegate:self];
  [controller setSelector:@selector(promptDataCameAvailable:)];
  [controller runModal];

  return aDefaultValue;
}

// Class using this mixin needs to define the following:
// - (void)promptDataCameAvailable:(CPString)responseValue
// {
// }

@end
