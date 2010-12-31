/*
 * All good things Javascript. All the various helpers that we require (i.e. those
 * things that aren't a method) can be defined here.
 */

// This takes a query string NOT a complete GET url.
// TODO should put this into a helpers class?
function getQueryVariables(query_str) {
  var store = [[CPDictionary alloc] init];
  var vars = query_str.split("&");
  for (var i=0;i<vars.length;i++) {
    var pair = vars[i].split("=");
    [store setObject:pair[1] forKey:pair[0]];
  } 
  return store;
}

@implementation CPTextField (CreateLabel)

+ (CPTextField)flickr_labelWithText:(CPString)aString
{
    var label = [[CPTextField alloc] initWithFrame:CGRectMakeZero()];
    
    [label setStringValue:aString];
    [label sizeToFit];
    [label setTextShadowColor:[CPColor whiteColor]];
    [label setTextShadowOffset:CGSizeMake(0, 1)];
    
    return label;
}

@end

@implementation AppController (Helpers)

- (CPView) createListPageNumbersView:(CGRect)aRect
{
  var aView = [[CPCollectionView alloc] initWithFrame:aRect];
  var pageNumberListItem = [[CPCollectionViewItem alloc] init];
  [pageNumberListItem setView:[[PageNumberListCell alloc] initWithFrame:CGRectMakeZero()]];

  [aView setDelegate:self];
  [aView setItemPrototype:pageNumberListItem];
  [aView setMinItemSize:CGSizeMake(20.0, 45.0)];
  [aView setMaxItemSize:CGSizeMake(1000.0, 45.0)];
  [aView setMaxNumberOfColumns:1];
  [aView setVerticalMargin:0.0];
  [aView setAutoresizingMask:CPViewWidthSizable];

  return aView;
}

- (CPTextField) createBitlyInfoBox:(CGRect)aRect
{
  var textField = [[CPTextField alloc] initWithFrame:aRect];
  [textField setStringValue:@""];
  [textField setSelectable:NO];
  [textField setEditable:NO];
  [textField setAlignment:CPCenterTextAlignment];
  [textField setVerticalAlignment:CPCenterVerticalTextAlignment];
  [textField setFont:[CPFont systemFontOfSize:12.0]];
  [textField setTextShadowColor:[CPColor blueColor]];
  [textField setTextShadowOffset:CGSizeMake(0, 1)];
  return textField;
}

@end
