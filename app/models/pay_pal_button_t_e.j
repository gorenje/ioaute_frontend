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
@implementation PayPalButtonTE : ToolElement
{
  CPString m_email @accessors(property=recipient);
  CPString m_currency @accessors(property=currency);
  CPString m_image_size @accessors(property=imageSize);
  CPString m_locale;
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super initWithJSONObject:anObject];
  if (self) {
    [PageElementInputSupport addToClass:[self class]];
    m_email    = _json.email;
    m_currency = ( typeof(_json.currency) == "undefined" ? "USD" : _json.currency );
    m_locale   = ( typeof(_json.locale) == "undefined" ? "en_US" : _json.locale );
    m_image_size = ( typeof(_json.image_size) == "undefined" ? "small" : _json.image_size );
  }
  return self;
}

- (void)promptDataCameAvailable:(CPString)responseValue
{
  if ( !(m_email === responseValue) ) {
    m_email = responseValue;
    [self updateServer];
  }
}

- (void)generateViewForDocument:(CPView)container
{
  if ( !m_email ) {
    m_email = [self obtainInput:("Enter recipient email, does not need to "+
                                 "have an PayPal account:")
                       defaultValue:"riessen@open-source-consultants.de"];
  }

  if (_mainView) {
    [_mainView removeFromSuperview];
  }

  _mainView = [[CPImageView alloc] initWithFrame:CGRectMakeCopy([container bounds])];
  [_mainView setAutoresizingMask:CPViewWidthSizable | CPViewHeightSizable];
  [_mainView setImageScaling:CPScaleProportionally];
  [_mainView setHasShadow:NO];
  [_mainView setImage:[self getImageForSize]];
  [container addSubview:_mainView];
}

- (void)getImageForSize
{
  var image = nil;
  switch ( [self imageSize] ) {
  case "small":
    image = [[PlaceholderManager sharedInstance] payPalButton];
    break;
  case "large":
    image = [[PlaceholderManager sharedInstance] payPalButtonLargeNoCC];
    break;
  case "large_with_cc":
    image = [[PlaceholderManager sharedInstance] payPalButtonLarge];
    break;
  }
  return image;
}

- (void)setImageSize:(CPString)aSize
{
  m_image_size = aSize;
  var image = [self getImageForSize];
  if ( image ) {
    [_mainView setImage:image];
    [self setFrameSize:[image size]];
    [self sendResizeToServer];
  }
}

- (CPImage)toolBoxImage
{
  return [[PlaceholderManager sharedInstance] toolPayPalButton];
}

- (CGSize) initialSize
{
  return [[self getImageForSize] size];
}

@end

@implementation PayPalButtonTE (Properties)

- (BOOL) hasProperties 
{ 
  return YES; 
}

- (void)openProperyWindow
{
  [[[PropertyPayPalButtonController alloc] 
     initWithWindowCibName:PayPalButtonPropertyWindowCIB 
               pageElement:self] showWindow:self];
}

@end
