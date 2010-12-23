@import <Foundation/CPObject.j>

/*
 * PM == publish me
 */
@implementation PMDataSource : CPObject
{
  JSObject _json;

  CPView _mainView;
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


@end
