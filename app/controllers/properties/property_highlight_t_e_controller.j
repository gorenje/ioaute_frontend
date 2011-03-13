@implementation PropertyHighlightTEController : PropertyWindowController
{
  @outlet CPColorWell m_color_well_bgcolor;
  @outlet CPButton m_clickable;
  @outlet CPTextField m_link_field;

  @outlet CPView m_view_bgcolor;
  @outlet CPView m_view_clickable;
  @outlet CPView m_border_width_view;

  @outlet CPButton m_show_as_border;
  @outlet CPSlider m_slider_border_width;
  @outlet CPTextField m_width_value;
  @outlet CPView m_link_value_view;

  //  @outlet CPButton m_visible_on_mouseover;

  CPColor m_originalColor;
}

- (void)awakeFromCib
{
  [super awakeFromCib];

  [CPBox makeBorder:m_color_well_bgcolor];
  [CPBox makeBorder:m_view_bgcolor];
  [CPBox makeBorder:m_view_clickable];

  [m_clickable setHidden:NO];
  [m_show_as_border setHidden:NO];
  [m_slider_border_width setValue:[m_pageElement borderWidth]];
  [self updateBorderWidthValueTextField];

  if ( [m_pageElement clickable] > 0 ) {
    [m_clickable setState:CPOnState];
    [m_link_value_view setHidden:NO];
  } else {
    [m_clickable setState:CPOffState];
    [m_link_value_view setHidden:YES];
  }

  if ( [m_pageElement showAsBorder] > 0 ) {
    [m_show_as_border setState:CPOnState];
    [m_border_width_view setHidden:NO];
  } else {
    [m_show_as_border setState:CPOffState];
    [m_border_width_view setHidden:YES];
  }

  [m_link_field setStringValue:[m_pageElement linkUrl]];
  m_originalColor = [m_pageElement getColor];
  [m_color_well_bgcolor setColor:m_originalColor];
}

//
// Actions galore
//
- (CPAction)accept:(id)sender
{
  [m_pageElement setHighlightColor:[m_color_well_bgcolor color]];
  [m_pageElement setLinkUrl:[m_link_field stringValue]];
  [m_pageElement setBorderWidth:[m_slider_border_width intValue]];
  [m_pageElement updateServer];
  [_window close];
}

- (CPAction)cancel:(id)sender
{
  [m_pageElement setHighlightColor:m_originalColor];
  [super cancel:sender];
}

- (CPAction)updateColor:(id)sender
{
  [m_pageElement setHighlightColor:[m_color_well_bgcolor color]];
}

- (CPAction)updateBorderWidth:(id)sender
{
  [self updateBorderWidthValueTextField];
}

- (CPAction)updateIsBorder:(id)sender
{
  if ( [m_show_as_border state] == CPOnState ) {
    [m_pageElement setShowAsBorder:1];
    [m_border_width_view setHidden:NO];
  } else {
    [m_pageElement setShowAsBorder:0];
    [m_border_width_view setHidden:YES];
  }
}

- (CPaction)updateClickable:(id)sender
{
  if ( [m_clickable state] == CPOnState ) {
    [m_pageElement setClickable:1];
    [m_link_value_view setHidden:NO];
  } else {
    [m_pageElement setClickable:0];
    [m_link_value_view setHidden:YES];
  }
}

//
// Helpoers
//
- (void) updateBorderWidthValueTextField
{
  var str = [CPString stringWithFormat:"%d px", [m_slider_border_width intValue]];
  [m_width_value setStringValue:str];
}

@end

