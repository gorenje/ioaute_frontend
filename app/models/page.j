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
@implementation Page : CPObject
{
  JSObject _json;

  CPString m_name        @accessors(property=name);
  CPString m_pageIdx     @accessors(property=pageIdx);
  int      m_number      @accessors(property=number);
  CPString m_size        @accessors(property=size);
  CPString m_orientation @accessors(property=orientation);
}

+ (CPArray)initWithJSONObjects:(CPArray)someJSONObjects
{
  return [PageElement generateObjectsFromJson:someJSONObjects forClass:self];
}

- (id)initWithJSONObject:(JSObject)anObject
{
  self = [super init];
  if (self) {
    [PageElementColorSupport addToClassOfObject:self];
    [ObjectStateSupport addToClassOfObject:self];

    _json            = anObject.page;
    m_number         = _json.number;
    m_name           = _json.name;
    m_pageIdx        = _json.id;
    m_size           = _json.size;
    m_orientation    = _json.orientation;
    [self setColorFromJson];
  }
  return self;
}

- (BOOL) isLetter
{
  return (m_size == "letter");
}

- (BOOL) isLandscape
{
  return (m_orientation == "landscape");
}

- (void)updateServer
{
  [[CommunicationManager sharedInstance] updatePage:self];
}

- (CGSize)getFrameSize
{
  var size;
  if ( [self isLetter]  ) {
    size = [[ConfigurationManager sharedInstance] getLetterSize];
  } else {
    size = [[ConfigurationManager sharedInstance] getA4Size];
  }
  if ( [self isLandscape] ) {
    size = CGSizeMake( size.height, size.width );
  }
  return size;
}

- (void)requestCompleted:(CPObject)data
{
  switch ( data.action ) {
  case "pages_update":
    if ( data.status == "ok" ) {
      // Is there anything we can do?
    }
    break;
  }
}

@end

@implementation Page (StateHandling)

- (CPArray)stateCreators
{
  return [@selector(name),        @selector(setName:),
          @selector(size),        @selector(setSize:),
          @selector(orientation), @selector(setOrientation:),
          @selector(getColor),    @selector(setColor:)];
}

- (void)postStateRestore
{
}

@end

