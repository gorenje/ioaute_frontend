
@import <Foundation/CPObject.j>

@implementation Flickr : CPObject
{
  CPString fromUser @accessors;
  CPString id_str   @accessors;
  JSObject json     @accessors;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super init];

  if (self) 
  {
    fromUser = anObject.owner;
    id_str   = anObject.id;
    json     = anObject;
  }

  return self;
}

- (CPString)flickrThumbUrlForPhoto
{
  var json = [self json];
  return ("http://farm" + json.farm + ".static.flickr.com/" + json.server+"/" +
          json.id + "_" + json.secret + "_m.jpg");
}

//
// Class method for creating an array of Flickr objects from JSON
//
+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  var objects = [[CPArray alloc] init];
    
  for (var idx = 0; idx < someJSONObjects.length; idx++) {
    [objects addObject:[[Flickr alloc] initWithJSONObject:someJSONObjects[idx]]];
  }
    
  return objects;
}

@end
