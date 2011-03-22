/*!
  Workaround for a bug in the CALayer composite function. See:
    http://githubissues.heroku.com/#280north/cappuccino/1183
*/
@implementation CALayerFixed : CALayer

- (void)composite
{
  var originalTransform = CGAffineTransformCreateCopy(_transformFromLayer);
  [super composite];
  _transformFromLayer = originalTransform;
}

@end
