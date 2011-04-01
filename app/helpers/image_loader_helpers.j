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
  Send off a request for an image and update the image view when the images arrives.
  In the meantime, set the spinner as image for the image view.
*/
@implementation ImageLoaderWorker : CPObject
{
  CPImage     m_image;
  CPImageView m_imageView;

  // called after the view has the image set.
  id m_delegate;
  SEL m_selector;
  // image is rotated if value is set and the image view 
  // responds to setRotationDegrees:
  int m_rotation_value;
  // whether the image is flipped
  BOOL m_is_vertical_flipped;
}

+ (ImageLoaderWorker)workerFor:(CPString)urlStr 
                     imageView:(CPImageView)aImageView
{
  return [[ImageLoaderWorker alloc] 
           initWithUrl:urlStr 
             imageView:aImageView
             tempImage:[[PlaceholderManager sharedInstance] spinner]
              delegate:nil
              selector:nil
              rotation:nil
            isVFlipped:NO];
}

+ (ImageLoaderWorker)workerFor:(CPString)urlStr 
                     imageView:(CPImageView)aImageView
{
  return [[ImageLoaderWorker alloc] 
           initWithUrl:urlStr 
             imageView:aImageView
             tempImage:[[PlaceholderManager sharedInstance] spinner]
              delegate:nil
              selector:nil
              rotation:nil
            isVFlipped:NO];
}

+ (ImageLoaderWorker)workerFor:(CPString)urlStr 
                     imageView:(CPImageView)aImageView
                   pageElement:(PageElement)aPageElement
{
  return [[ImageLoaderWorker alloc] 
           initWithUrl:urlStr 
             imageView:aImageView
             tempImage:[[PlaceholderManager sharedInstance] spinner]
              delegate:nil
              selector:nil
              rotation:[aPageElement rotation]
            isVFlipped:[aPageElement isVerticalFlipped]];
}

+ (ImageLoaderWorker)workerFor:(CPString)urlStr 
                     imageView:(CPImageView)aImageView
                      rotation:(int)aRotationValue
{
  return [[ImageLoaderWorker alloc] 
           initWithUrl:urlStr 
             imageView:aImageView
             tempImage:[[PlaceholderManager sharedInstance] spinner]
              delegate:nil
              selector:nil
              rotation:aRotationValue
            isVFlipped:NO];
}

+ (ImageLoaderWorker)workerFor:(CPString)urlStr 
                     imageView:(CPImageView)aImageView 
                     tempImage:(CPImage)aImage
{
  return [[ImageLoaderWorker alloc] 
           initWithUrl:urlStr 
             imageView:aImageView
             tempImage:aImage
              delegate:nil
              selector:nil
              rotation:nil
            isVFlipped:NO];
}

+ (ImageLoaderWorker)workerFor:(CPString)urlStr 
                     imageView:(CPImageView)aImageView
                      delegate:(id)aDelegate
                      selector:(SEL)aSelector
{
  return [[ImageLoaderWorker alloc] 
           initWithUrl:urlStr 
             imageView:aImageView
             tempImage:[[PlaceholderManager sharedInstance] spinner]
              delegate:aDelegate
              selector:aSelector
              rotation:nil
            isVFlipped:NO];
}

- (id)initWithUrl:(CPString)urlStr 
        imageView:(CPImageView)anImageView 
        tempImage:(CPImage)aTempImage
         delegate:(id)aDelegate
         selector:(SEL)aSelector
         rotation:(int)rotDeg
       isVFlipped:(BOOL)aVFlipValue
{
  self = [super init];
  if (self) {
    m_imageView           = anImageView;
    m_image               = [[CPImage alloc] initWithContentsOfFile:urlStr];
    m_delegate            = aDelegate;
    m_selector            = aSelector;
    m_rotation_value      = rotDeg;
    m_is_vertical_flipped = aVFlipValue;

    [m_image setDelegate:self];
    if ([m_image loadStatus] != CPImageLoadStatusCompleted &&
        [aTempImage loadStatus] == CPImageLoadStatusCompleted) {
      [m_imageView setImage:aTempImage];
    }
  }
  return self;
}

- (void)imageDidLoad:(CPImage)anImage
{
  [m_imageView setImage:anImage];

  if ( m_rotation_value && [m_imageView respondsToSelector:@selector(setRotationDegrees:)]) {
    [m_imageView setRotationDegrees:m_rotation_value];
  }

  if ( m_is_vertical_flipped && [m_imageView respondsToSelector:@selector(setVerticalFlip:)] ) {
    [m_imageView setVerticalFlip:1];
  }
  
  if ( m_delegate && m_selector ) {
    [m_delegate performSelector:m_selector withObject:anImage];
  }
}

@end

/*!
  Used by the placeholder to manage it's images. This is the same as above except
  it loads from a "local" path and not URL.
*/
@implementation PMGetImageWorker : CPObject
{
  CPImage image @accessors;
  CPString path @accessors;
}

+ (PMGetImageWorker)workerFor:(CPString)pathStr
{
  return [[PMGetImageWorker alloc] initWithPath:pathStr];
}

- (id)initWithPath:(CPString)pathStr
{
  self = [super init];
  if (self) {
    path = pathStr;
    image = [[CPImage alloc] initWithContentsOfFile:path];
    [image setDelegate:self];
  }
  return self;
}

- (void)imageDidLoad:(CPImage)anImage
{
  image = anImage;
}

@end
