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
@implementation ToolViewController : CPObject
{
  CPView m_collectionView;
}

+ (CPView) createToolsCollectionView:(CGRect)aRect
{
  var aView = [[CPCollectionView alloc] initWithFrame:aRect];
  var toolListItem = [[CPCollectionViewItem alloc] init];
  [toolListItem setView:[[ToolListCell alloc] initWithFrame:CGRectMakeZero()]];

  [[ToolViewController alloc] initWithView:aView];

  [aView setItemPrototype:toolListItem];
  [aView setMinItemSize:CGSizeMake(117.0, 80.0)];
  [aView setMaxItemSize:CGSizeMake(117.0, 80.0)];
  [aView setMaxNumberOfColumns:2];
  [aView setVerticalMargin:0.0];
  [aView setAutoresizingMask:CPViewWidthSizable];
  [aView setSelectable:YES];
  [aView setAllowsMultipleSelection:NO];
  [aView setAllowsEmptySelection:NO];

  return aView;
}

- (id)initWithView:(CPView)aView
{
  self = [super init];
  if ( self ) {
    m_collectionView = aView;
    [m_collectionView setDelegate:self];

    [[CPNotificationCenter defaultCenter]
            addObserver:self
               selector:@selector(toolBoxItemsHaveArrived:)
                   name:ConfigurationManagerToolBoxArrivedNotification
                 object:nil]; // object is a list of tool box items

  }
  return self;
}

- (void)toolBoxItemsHaveArrived:(CPNotification)aNotification
{
  var content = [[DragDropManager sharedInstance] 
                   moreToolElements:[ToolElement 
                                      initWithJSONObjects:[aNotification object]]];
  [m_collectionView setContent:content];
}

- (CPData)collectionView:(CPCollectionView)aCollectionView
   dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
  var idx_store = [];
  [indices getIndexes:idx_store maxCount:([indices count] + 1) inIndexRange:nil];

  var data = [];
  var toolElements = [m_collectionView content];
  for (var idx = 0; idx < [idx_store count]; idx++) {
    [data addObject:[toolElements[idx_store[idx]] id_str]];
  }
  return [CPKeyedArchiver archivedDataWithRootObject:data];
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView 
   dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
  return [ToolElementDragType];
}

@end
