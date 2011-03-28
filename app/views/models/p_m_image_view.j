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
  Similar to CPImageView but implementing the display of images using CALayers and not 
  views. This allows to do rotation and other transformations on the image.
  
  This is heavily borrowed from ScrapBook example, part 1 ==>
     http://cappuccino.org/learn/tutorials/scrapbook-tutorial-1/
*/
@implementation PMImageView : CPImageView
{
  CALayer m_imageLayer;
  CPImage m_image @accessors(property=image,readonly);
  float   m_rotationRadians;
}

- (id)initWithFrame:(CGRect)aFrame
{
  self = [super initWithFrame:aFrame];
  if ( self ) {
    m_rotationRadians = 0.0;
    m_image           = nil;
    m_imageLayer      = [CALayer layer];
    [m_imageLayer setDelegate:self];

    [self setClipsToBounds:NO];
    [self setWantsLayer:YES];
    [self setLayer:m_imageLayer];
  }
  return self;
}

- (void)setRotationDegrees:(int)aDegreeValue
{
  [self setRotationRadians:( aDegreeValue * (Math.PI / 180) )];
}

- (void)setRotationRadians:(float)radians
{
  if (m_rotationRadians == radians) return;
  m_rotationRadians = radians;
  [m_imageLayer setAffineTransform:CGAffineTransformMakeRotation(m_rotationRadians)];
}

/*!
  Set the image. Assumed is that the image is completed loaded. The status of the image
  should be checked before calling this method, e.g.:

    if ( [anImage loadStatus] == CPImageLoadStatusCompleted ) {
      [self setImage:anImage]
    }
*/
- (void)setImage:(CPImage)anImage
{
  if (m_image == anImage) return;
  m_image = anImage;
  [self setFrameOrigin:CGPointMake(0,0)];
  [self setFrameSize:CGSizeMake( [self frame].size.width, [self frame].size.height ) ];
  [m_imageLayer setNeedsDisplay];
}

- (void)drawLayer:(CALayer)aLayer inContext:(CGContext)aContext
{
  if ( m_image ) CGContextDrawImage(aContext, [aLayer bounds], m_image);
}

@end
