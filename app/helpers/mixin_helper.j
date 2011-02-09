/*
 * Taken from https://gist.github.com/818278
 */
@implementation MixinHelper : CPObject

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
