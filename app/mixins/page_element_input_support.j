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
