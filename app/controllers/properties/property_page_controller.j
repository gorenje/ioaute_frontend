/*
 * This might be the page property controller, however we never communicate directly
 * with the page object, rather via the document view controller (DVC). The DVC 
 * responsible for maintaining the document view in the editor, so it also needs 
 * to know about color changes etc. Therefore it makes sense that the DVC notifies the
 * current page object of any changes.
 *
 * This also has the advantage that if the user decides to change pages, the current 
 * page (that is shown) is modified.
 */
@implementation PropertyPageController : PropertyWindowController
{
  @outlet CPColorWell   m_colorWell;

  @outlet CPButton   m_size_a4;
  @outlet CPButton   m_size_letter;

  @outlet CPButton   m_orientation_portrait;
  @outlet CPButton   m_orientation_landscape;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [CPBox makeBorder:m_colorWell];

  var pageObj = [[PageViewController sharedInstance] currentPage];

  [m_colorWell setColor:[pageObj getColor]];
  if ( [pageObj isLandscape] ) {
    [m_orientation_landscape setState:CPOnState];
  } else {
    [m_orientation_portrait setState:CPOnState];
  }

  if ( [pageObj isLetter] ) {
    [m_size_letter setState:CPOnState];
  } else {
    [m_size_a4 setState:CPOnState];
  }
}

- (CPAction)updateColor:(id)sender
{
  [[DocumentViewController sharedInstance] setBackgroundColor:[m_colorWell color]];
}

- (CPAction)updateSize:(id)sender
{
  if ( sender == m_size_a4 ) {
    [[DocumentViewController sharedInstance] setPageSize:"a4"];
  } else {
    [[DocumentViewController sharedInstance] setPageSize:"letter"];
  }
}

- (CPAction)updateOrientation:(id)sender
{
  if ( sender == m_orientation_landscape ) {
    [[DocumentViewController sharedInstance] setPageOrientation:"landscape"];
  } else {
    [[DocumentViewController sharedInstance] setPageOrientation:"portrait"];
  }
}

- (CPAction)accept:(id)sender
{
  [[DocumentViewController sharedInstance] updateServer];
  [_window close];
}

@end
