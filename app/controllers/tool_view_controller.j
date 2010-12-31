@import <Foundation/CPObject.j>


@implementation ToolViewController : CPObject
{
  CPView _collectionView;
}

+ (CPView) createToolsCollectionView:(CGRect)aRect
{
  var aView = [[CPCollectionView alloc] initWithFrame:aRect];
  var toolListItem = [[CPCollectionViewItem alloc] init];
  [toolListItem setView:[[ToolListCell alloc] initWithFrame:CGRectMakeZero()]];

  [[ToolViewController alloc] initWithView:aView];

  [aView setItemPrototype:toolListItem];
  [aView setMinItemSize:CGSizeMake(45.0, 45.0)];
  [aView setMaxItemSize:CGSizeMake(45.0, 45.0)];
  [aView setMaxNumberOfColumns:2];
  [aView setVerticalMargin:0.0];
  [aView setAutoresizingMask:CPViewWidthSizable];
  [aView setSelectable:YES];
  [aView setAllowsMultipleSelection:NO];

  [aView setContent:[ToolViewController createToolElememnts]];
  return aView;
}

+ (CPArray) createToolElememnts
{
  var ary = [
             '{ "id": "1", "name" : "Text" }',
             '{ "id": "2", "name" : "FileContent" }',
             '{ "id": "3", "name" : "ImageURL" }',
             '{ "id": "4", "name" : "Link" }',
             ];

  var tools = [];
  var idx = ary.length;
  while ( idx-- ) {
    tools.push([[ToolElement alloc] initWithJSONObject:[ary[idx] objectFromJSON]]);
  }

  // TODO push these to the drag&drop manager so that we can retreive tools just as 
  // TODO all other page elements.
  return tools;
}

- (id)initWithView:(CPView)aView
{
  self = [super init];
  if ( self ) {
    _collectionView = aView;
    [_collectionView setDelegate:self];
  }
  return self;
}

- (CPData)collectionView:(CPCollectionView)aCollectionView dataForItemsAtIndexes:(CPIndexSet)indices forType:(CPString)aType
{
  // TODO implement this.
  return nil;
}

- (CPArray)collectionView:(CPCollectionView)aCollectionView dragTypesForItemsAtIndexes:(CPIndexSet)indices
{
  return [ToolElementDragType];
}

@end
