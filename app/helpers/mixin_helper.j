/*
 * Taken from https://gist.github.com/818278
 */
@implementation MixinHelper : CPObject

+ (void)addToClassOfObject:(CPObject)anObject
{
  [self mixIntoClass:[anObject class] usingClass:self];
}

+ (void)addToClass:(id)aClass
{
  [self mixIntoClass:aClass usingClass:self];
}

+ (void)mixIntoClass:(id)targetClass usingClass:(id)mixinClass
{
  class_addIvars(targetClass, class_copyIvarList(mixinClass));
  class_addMethods(targetClass, class_copyMethodList(mixinClass) );
}

@end
