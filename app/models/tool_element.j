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
 * Specialisation of a PageElement representing a tool. Tools don't get initialized by
 * an external source (e.g. Facebook, Twitter, etc) rather they represent specific tools.
 * Tools can be initialized by the user directly (if required), for example, by providing the
 * URL for a image or just appear (e.g. Moustache tool) completely initialized.
 *
 * Initialization via the user should be done in the generateViewForDocument method using,
 * for example, a prompt(...) call. If a tool does have user specific data, then this
 * needs to be communicated to the server. For this, create an instance variable and this
 * will be automagically sent to the server (see image_t_e.j for an example). On the server
 * side, the class representing this object needs to read this information and store it
 * in the database.
 */
@implementation ToolElement : PageElement

+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  var objAry = [];
  var idx = someJSONObjects.length;

  while ( idx-- ) {
    var klazz = CPClassFromString(someJSONObjects[idx].klazz);
    objAry.push( [[klazz alloc] initWithJSONObject:someJSONObjects[idx]] );
  }

  return objAry;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
  }
  return self;
}

- (CPString) name
{
  return _json.name;
}

- (CPString) id_str
{
  return _json.id;
}

- (CPString) toolTip
{
  return _json.tool_tip;
}

- (void)generateViewForDocument:(CPView)container
{
  // Default is to pop up a todo alert.
  [AlertUserHelper withTodo:@"This tool is still being built"];
}

- (CPImage)toolBoxImage
{
  // *** This needs to be implemented by the subclass ***
  //
  // Replace this with our tool image. This is image is incorporated into the tool box
  // used to drag tools into the publication.
  return [[PlaceholderManager sharedInstance] toolUnknown];
}

- (CGSize) initialSizeFromJsonOrDefault:(CGSize)defaultSize
{
  if ( is_defined( _json.width ) && is_defined( _json.height ) ) {
    return CGSizeMake([_json.width doubleValue], [_json.height doubleValue]);
  } else {
    return defaultSize;
  }
}

@end
