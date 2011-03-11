/*
 * Mixin for supporting the retrieval and checking of data from the user. I.e. quickly
 * throw up an input window and obtain some information from the user.
 */
@implementation PageElementInputSupport : MixinHelper

- (CPString) obtainInput:(CPString)aPrompt defaultValue:(CPString)aDefaultValue
{
  var inputString = prompt( aPrompt );
  if ( !inputString ) {
    return aDefaultValue;
  }

  inputString = [inputString stringByTrimmingWhitespace];
  if ( [inputString isBlank] ) {
    return aDefaultValue;
  }
  
  return inputString;
}

@end
