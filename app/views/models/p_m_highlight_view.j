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

@implementation PMHighlightView : CPView
{
  CALayer     m_rootLayer;
  HighlightTE m_highlightElement;
}

- (id)initWithFrame:(CGRect)aFrame 
   highlightElement:(HighlightTE)aHighlightElement
{
  self = [super initWithFrame:aFrame];
  if ( self ) {
    m_rotationRadians  = 0.0;
    m_rootLayer        = [CALayer layer];
    m_highlightElement = aHighlightElement;
    [m_rootLayer setDelegate:self];
    [self setClipsToBounds:NO];
    [self setWantsLayer:YES];
    [self setLayer:m_rootLayer];
  }
  return self;
}

- (void)redisplay
{
  [m_rootLayer setNeedsDisplay];
}

- (void)setRotationDegrees:(int)aDegreeValue
{
  [self setRotationRadians:( aDegreeValue * (Math.PI / 180) )];
}

- (void)setRotationRadians:(float)radians
{
  if (m_rotationRadians === radians) return;
        
  m_rotationRadians = radians;
  [m_rootLayer setAffineTransform:CGAffineTransformMakeRotation(m_rotationRadians)];
}

- (void)drawLayer:(CALayer)aLayer inContext:(CGContext)aContext
{
  var bounds = [aLayer bounds];
  CGContextSetFillColor(aContext, [m_highlightElement getColor]);
  CGContextSetStrokeColor(aContext, [m_highlightElement getColor]);

  if ( [m_highlightElement showAsBorder] == 0 ) {
    var path = [self roundedRectangleInRect:bounds];
    CGContextBeginPath(aContext);
    CGContextAddPath(aContext, path);
    CGContextClosePath(aContext);
    CGContextFillPath(aContext);
  } else {
    bounds = CGRectInset( bounds, [m_highlightElement borderWidth]/2,
                          [m_highlightElement borderWidth]/2);
    var path = [self roundedRectangleInRect:bounds];
    CGContextBeginPath(aContext);
    CGContextAddPath(aContext, path);
    CGContextClosePath(aContext);
    CGContextSetLineWidth(aContext, [m_highlightElement borderWidth]);
    CGContextStrokePath(aContext);
  }
}

- (CGRect)boundingBox
{
  return [m_rootLayer backingStoreFrame];
}

/*!
  Generate a path for a rounded cornered rectangle.

  Code based on CGPath.j#CGPathWithRoundedRectangleInRect
*/
- (CGPath)roundedRectangleInRect:(CGRect)aRect
{
  var path = CGPathCreateMutable(),
    xMin = CGRectGetMinX(aRect),
    xMax = CGRectGetMaxX(aRect),
    yMin = CGRectGetMinY(aRect),
    yMax = CGRectGetMaxY(aRect);

  CGPathMoveToPoint(path, nil, xMin + [m_highlightElement cornerTopLeft], yMin);

  if ( [m_highlightElement cornerTopRight] > 0 )
  {
    CGPathAddLineToPoint(path, nil, xMax - [m_highlightElement cornerTopRight], yMin);
    CGPathAddCurveToPoint(path, nil, xMax - [m_highlightElement cornerTopRight], yMin, 
                          xMax, yMin, xMax, yMin + [m_highlightElement cornerTopRight]);
  }
  else
    CGPathAddLineToPoint(path, nil, xMax, yMin);

  if ( [m_highlightElement cornerBottomRight] > 0 )
  {
    CGPathAddLineToPoint(path, nil, xMax, yMax - [m_highlightElement cornerBottomRight]);
    CGPathAddCurveToPoint(path, nil, xMax, yMax - [m_highlightElement cornerBottomRight], 
                          xMax, yMax, xMax - [m_highlightElement cornerBottomRight], yMax);
  }
  else
    CGPathAddLineToPoint(path, nil, xMax, yMax);

  if ([m_highlightElement cornerBottomLeft] > 0)
  {
    CGPathAddLineToPoint(path, nil, xMin + [m_highlightElement cornerBottomLeft], yMax);
    CGPathAddCurveToPoint(path, nil, xMin + [m_highlightElement cornerBottomLeft], yMax, 
                          xMin, yMax, xMin, yMax - [m_highlightElement cornerBottomLeft]);
  }
  else
    CGPathAddLineToPoint(path, nil, xMin, yMax);

  if ([m_highlightElement cornerTopLeft] > 0)
  {
    CGPathAddLineToPoint(path, nil, xMin, yMin + [m_highlightElement cornerTopLeft]);
    CGPathAddCurveToPoint(path, nil, xMin, yMin + [m_highlightElement cornerTopLeft], 
                          xMin, yMin, xMin + [m_highlightElement cornerTopLeft], yMin);
  }
  else
    CGPathAddLineToPoint(path, nil, xMin, yMin);

  CGPathCloseSubpath(path);

  return path;
}

@end
