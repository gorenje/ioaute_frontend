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
/*
 * Controller for managing the document view which is our publication or 
 * rather one page of that publication.
 *
 * This stores all the PageElement objects for all the pages in the current document.
 * The DocumentView manages the DocumentViewCells and nothing else. The PageElement
 * and DocumentViewCell send messages, at least partially, direct to this singleton
 * class. This class is then responsible for updating the DocumentView.
 */

var DocumentViewControllerInstance = nil;

@implementation DocumentViewController : CPObject
{
  int m_z_index_value;
  int m_current_page_idx;

  CPDictionary m_pageStore;
  // views for containing the document view.
  CPView m_bgView;
  CPShadowView m_shadowView @accessors(property=shadowView,readonly);
  DocumentView m_documentView;
}

- (id)init
{
  self = [super init];
  if (self) {
    m_z_index_value = 0;
    m_current_page_idx = -1;
    m_pageStore = [[CPDictionary alloc] init];

    [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(pageNumberDidChange:)
                   name:PageViewPageNumberDidChangeNotification
                 object:nil]; // object is the new page being shown.

    [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(clearDocumentView:)
                   name:PageViewLastPageWasDeletedNotification
                 object:[PageViewController sharedInstance]];

    [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(pageWasDeleted:)
                   name:PageViewPageWasDeletedNotification
                 object:nil]; // object is the page being deleted.
  }
  return self;
}

+ (DocumentViewController) sharedInstance 
{
  if ( !DocumentViewControllerInstance ) {
    if ( [[ConfigurationManager sharedInstance] is_new] ) {
      DocumentViewControllerInstance = [[DocumentViewController alloc] init];
    } else {
      DocumentViewControllerInstance = [[DocumentViewControllerEditExisting alloc] init];
    }
  }
  return DocumentViewControllerInstance;
}

+ (CPView)createDocumentView
{
  var sizeA4 = [[ConfigurationManager sharedInstance] getA4Size];
  var bgView = [[CPView alloc] 
                 initWithFrame:CGRectMake(0, 0, sizeA4.height+60, sizeA4.height+60)];
  [bgView setAutoresizesSubviews:NO];
  [bgView setAutoresizingMask:CPViewNotSizable];
  [[DocumentViewController sharedInstance] addDocumentViewTo:bgView];
  return bgView;
}

- (void)addDocumentViewTo:(CPView)parent
{
  var sizeA4 = [[ConfigurationManager sharedInstance] getA4Size];
  var rectA4 = CGRectMake(30, 30, sizeA4.width, sizeA4.height);

  m_bgView = parent;

  m_shadowView = [[CPShadowView alloc] initWithFrame:CGRectInset(rectA4, -7, -5)];
  [m_shadowView setAutoresizingMask:CPViewNotSizable];
  [m_shadowView setWeight:CPHeavyShadow];

  m_documentView = [[DocumentView alloc] initWithFrame:rectA4];
  [m_documentView setHidden:YES];
  [m_shadowView setHidden:YES];

  [parent addSubview:m_shadowView];
  [parent addSubview:m_documentView];
}

- (CPString)currentPage
{
  return [[[PageViewController sharedInstance] currentPage] pageIdx];
}

/*! 
  Return the store (i.e. CPDictionary) for the current page. If there is no store
  then create one, store it and return it. This could be done better by capturing the 
  notification for a new page being created. But since there is (at time of writing)
  no notification, that is fairly pointless.
*/
- (CPArray)currentStore
{
  var current_page = [self currentPage];
  var local_store = [m_pageStore objectForKey:current_page];
  if ( !local_store ) {
    local_store = [[CPArray alloc] init];
    [m_pageStore setObject:local_store forKey:current_page];
  }
  return local_store;
}

- (void)addPageToStore:(Page)page withPageElements:(JSObject)pageElements
{
  [[self getStoreForPage:page]
          addObjectsFromArray:[PageElement createObjectsFromServerJson:pageElements]];
}

- (CPArray)getStoreForPage:(Page)pageObj
{
  var local_store = [m_existingPages objectForKey:[pageObj pageIdx]];
  if ( !local_store ) {
    local_store = [[CPArray alloc] init];
    [m_existingPages setObject:local_store forKey:[pageObj pageIdx]];
  }
  return local_store;
}

/*!
  Returns a list of all elements of a particular type in the entire publication.

  Admittedly the 'orType' could be generalised to be an array of types ... but
  was late when this code was written :-)
*/
- (CPArray)allPageElementsOfType:(id)aPageElementClass orType:(id)aSecondType
{
  var ary = [];
  var psAllKeys = [m_pageStore allKeys];
  for ( var idx = 0; idx < [psAllKeys count]; idx++ ) {
    var psAllElements = [m_pageStore objectForKey:psAllKeys[idx]];
    for ( var jdx = 0; jdx < [psAllElements count]; jdx++ ) {
      if ( [psAllElements[jdx] class] === aPageElementClass || 
           [psAllElements[jdx] class] === aSecondType ) {
        ary.push(psAllElements[jdx]);
      }
    }
  }
  return ary;
}


//
// Notification from the page view that a new page has been selected. Retrieve
// the contents of the page from the page store.
//
- (void)pageNumberDidChange:(CPNotification)aNotification
{
  // hide editor highlight
  var pageObj = [aNotification object];

  // prevent re-rendering of the same page.
  if ( m_current_page_idx == [pageObj pageIdx] ) return;
  m_current_page_idx = [pageObj pageIdx]; 

  [[DocumentViewEditorView sharedInstance] setDocumentViewCell:nil];
  [m_documentView setContent:[self currentStore]];
  [m_documentView setBackgroundColor:[pageObj getColor]];
  [self updatePageSize:[pageObj getFrameSize]];
  [m_shadowView setHidden:![[[ConfigurationManager sharedInstance] pubProperties] hasShadow]];
  [m_documentView setHidden:NO];
}

- (void)pageWasDeleted:(CPNotification)aNotification
{
  var pageObj = [aNotification object];
  var local_store = [m_pageStore objectForKey:[pageObj pageIdx]];
  if ( local_store ) {
    [local_store removeAllObjects];
  }
}

- (void)clearDocumentView:(CPNotification)aNotification
{
  [[DocumentViewEditorView sharedInstance] setDocumentViewCell:nil];
  [m_documentView setContent:[]];
}

- (void)setBackgroundColor:(CPColor)aColor
{
  [m_documentView setBackgroundColor:aColor];
  [[[PageViewController sharedInstance] currentPageObj] setColor:aColor];
}

- (CPColor)backgroundColor
{
  return [m_documentView backgroundColor];
}

- (CPString)pageOrientation
{
  return [[[PageViewController sharedInstance] currentPageObj] orientation];
}

- (void)setPageOrientation:(CPString)orientation
{
  var pageObj = [[PageViewController sharedInstance] currentPageObj];
  [pageObj setOrientation:orientation];
  [self updatePageSize:[pageObj getFrameSize]];
}

- (CPString)pageSize
{
  return [[[PageViewController sharedInstance] currentPageObj] size];
}

- (void)setPageSize:(CPString)aSize
{
  var pageObj = [[PageViewController sharedInstance] currentPageObj];
  [pageObj setSize:aSize];
  [self updatePageSize:[pageObj getFrameSize]];
}

- (void)updateServer
{
  [[[PageViewController sharedInstance] currentPageObj] updateServer];
}

- (void)updatePageSize:(CGSize)aPageSize
{
  [m_documentView setFrameSize:aPageSize];
  [m_bgView setFrameSize:CGSizeMake( aPageSize.width + 60, aPageSize.height + 60 )];
  [m_shadowView setFrameSize:CGSizeMake( aPageSize.width + 14, aPageSize.height + 10 )];
}

//
// Callbacks from the document view. A bunch of page elements were just dumped
// into the document view. These are all new and need to be added to the server
// and our store for the current page.
//
- (void)draggedObjects:(CPArray)pageElements atLocation:(CGPoint)aLocation
{
  [self addObjectsToView:pageElements atLocation:aLocation];
  for ( var idx = 0; idx < pageElements.length; idx++ ) {
    [pageElements[idx] addToServer];
  }
}

- (CPArray)addObjectsToView:(CPArray)pageElements 
              atLocation:(CGPoint)aLocation
{
  [[self currentStore] addObjectsFromArray:pageElements];
  return [m_documentView addObjectsToView:pageElements atLocation:aLocation];
}

- (CPPoint)currentMidPoint
{
  return [m_documentView convertPoint:CGPointMake( CGRectGetMidX([m_documentView frame]),
                                                   CGRectGetMidY([m_documentView frame]))
                               toView:nil];
}

//
// Callback from PageElement. The server has been informed by the page element,
// we only need to remove it from our local store for the page.
//
- (void)removeObject:(PageElement)obj
{
  var keys = [m_pageStore allKeys];
  for ( var idx = 0; idx < keys.length; idx++ ) {
    [[m_pageStore objectForKey:keys[idx]] removeObjectIdenticalTo:obj];
  }
}

// TODO TODO implement me properly.
- (int)nextZIndex
{
  var pageElements = [self currentStore];
  [pageElements sortUsingSelector:@selector(compareZ:)];
  return ([pageElements[0] zIndex] + 1);
}

@end
