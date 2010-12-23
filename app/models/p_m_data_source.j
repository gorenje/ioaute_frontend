@import <Foundation/CPObject.j>

/*
 * PM == publish me
 */
@implementation PMDataSource : CPObject
{
  JSObject _json;
  /*
   * Use the _mainView as the view reference. I.e. generateViewForDocument
   * must initialise this instance variable. This then allows for more generalisation.
   */
  CPView _mainView;
}

/*
 * Used by subclasses to generate a bunch of classes from JSON Data that came
 * back over the wire.
 */
+ (CPArray) generateObjectsFromJson:(CPArray)someJSONObjects forClass:(CPObject)klass
{
  var objects = [[CPArray alloc] init];
  for (var idx = 0; idx < someJSONObjects.length; idx++) {
    [objects addObject:[[klass alloc] initWithJSONObject:someJSONObjects[idx]]] ;
  }
  return objects;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super init];

  if (self) {
    _json = anObject;
  }

  return self;
}

- (CPObject)clone
{
  return [[[self class] alloc] initWithJSONObject:_json];
}

- (CPString) id_str
{
  // This needs to be implemented by the subclass and provides a unique id _string_
  // across all objects of the same class. This is normally the id used by the
  // DataSource provider, i.e. Twitter, Flickr, etc.
}

- (void)removeFromSuperview
{
  [_mainView removeFromSuperview];
}

- (void)generateViewForDocument:(CPView)container
{
  // this needs to be implemented by the subclass.
}
@end
