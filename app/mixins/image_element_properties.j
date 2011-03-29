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
  An image can also be rotated, so we include the rotation support into the class we've
  been mixed into.
*/
@implementation ImageElementProperties : GRClassMixin
{
  CPString m_destUrl        @accessors(property=linkUrl);
  int      m_reloadInterval @accessors(property=reloadInterval);
}

/*!
  Hook called once we've been included in a class. This allows use to include the
  rotation support into the class.
*/
+ (void)includedInClass:(id)targetClass
{
  [PageElementRotationSupport addToClass:targetClass];
}

- (void)setImagePropertiesFromJson
{
  m_destUrl        = _json.dest_url;
  m_reloadInterval = [check_for_undefined(_json.reload_interval,"0") intValue];
}

/*!
  Extra functionality for specific classes, e.g. facebook.
*/
- (void) setDestUrlFromJson:(CPString)alternativeUrl
{
  m_destUrl = is_defined(_json.dest_url) ? _json.dest_url : alternativeUrl;
}

- (BOOL) hasProperties 
{ 
  return YES; 
}

- (void)openProperyWindow
{
  [[[PropertyImageTEController alloc] initWithWindowCibName:ImageTEPropertyWindowCIB 
                                                pageElement:self] showWindow:self];
}

// The following two need to be implemented by the class that uses this mixin.
//   - (void)setImageUrl:(CPString)aString { }
//   - (CPString)imageUrl { }
// We don't define these here because this mixin would override the class' 
// implementation of these methods.

- (CGSize)getImageSize
{
  return [[_mainView image] size];
}

/*!
  Assume that rotation support is also activated.
*/
- (void)generateViewForDocument:(CPView)container withUrl:(CPString)url
{
  if (_mainView) [_mainView removeFromSuperview];

  _mainView = [[PMImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleToFit];
  [_mainView setHasShadow:NO];
  [ImageLoaderWorker workerFor:url imageView:_mainView rotation:[self rotation]];
  [container addSubview:_mainView];
}

@end

@implementation ImageElementProperties (StateHandling)

- (CPArray)stateCreators
{
  return [[self rotationSupportStateHandlers] 
           arrayByAddingObjectsFromArray:[@selector(linkUrl), @selector(setLinkUrl:),
                                          @selector(reloadInterval),
                                                 @selector(setReloadInterval:),
                                          @selector(getSize), @selector(setFrameSize:)]];
}

- (void)postStateRestore
{
}

@end
