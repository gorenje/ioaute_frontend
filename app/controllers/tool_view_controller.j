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
                   moreToolElements:[ToolElement initWithJSONObjects:[aNotification object]]];
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
