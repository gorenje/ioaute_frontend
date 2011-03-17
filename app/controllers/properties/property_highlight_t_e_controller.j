@implementation PropertyHighlightTEController : PropertyWindowController
{
  @outlet CPColorWell m_color_well_bgcolor;

  @outlet CPButton m_clickable;
  @outlet CPButton m_show_as_border;
  @outlet CPButton m_rounded_corners;

  @outlet CPTextField m_link_field;
  @outlet CPTextField m_rotation_field;
  @outlet CPTextField m_width_value;

  @outlet CPView m_view_bgcolor;
  @outlet CPView m_view_clickable;
  @outlet CPView m_view_rounded_corners;
  @outlet CPView m_border_width_view;
  @outlet CPView m_rotation_view;
  @outlet CPView m_rounded_corners_example;
  @outlet CPView m_link_value_view;

  @outlet CPSlider m_rotation_slider;
  @outlet CPSlider m_slider_border_width;
  
  CPColor m_originalColor;
}

- (void)awakeFromCib
{
  [super awakeFromCib];

  [CPBox makeBorder:m_view_bgcolor];
  [CPBox makeBorder:m_rotation_view];
  [CPBox makeBorder:m_view_clickable];
  [CPBox makeBorder:m_color_well_bgcolor];
  [CPBox makeBorder:m_rounded_corners_example];

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

  if ( [m_pageElement hasRoundedCorners] ) {
    [m_rounded_corners setState:CPOnState];
    [m_view_rounded_corners setHidden:NO];
  } else {
    [m_rounded_corners setState:CPOffState];
    [m_view_rounded_corners setHidden:YES];
  }

  var values = [[m_pageElement cornerTopLeft],    
                [m_pageElement cornerTopRight],
                [m_pageElement cornerBottomLeft], 
                [m_pageElement cornerBottomRight]];
  [self setCornerSliders:values];

  [m_link_field setStringValue:[m_pageElement linkUrl]];
  m_originalColor = [m_pageElement getColor];
  [m_color_well_bgcolor setColor:m_originalColor];
  [m_rounded_corners_example setBackgroundColor:m_originalColor];

  [m_rotation_slider setValue:[m_pageElement rotation]];
  [self setRotationValue:m_rotation_slider];
}

//
// Actions galore
//
- (CPAction)toggleCorners:(id)sender
{
  if ( [m_rounded_corners state] == CPOnState ) {
    [m_view_rounded_corners setHidden:NO];
  } else {
    [self setCornerSliders:[0,0,0,0]];
    [m_view_rounded_corners setHidden:YES];
  }
}

- (CPAction)setCornerValue:(id)sender
{
  if ( [sender isKindOfClass:CPSlider] ) {
    [[self findViewWithTag:[sender tag]
                   inViews:[m_view_rounded_corners subviews]
                   ofClass:CPTextField] 
      setStringValue:(""+[sender intValue])];
  } else {
    [[self findViewWithTag:[sender tag]
                   inViews:[m_view_rounded_corners subviews]
                   ofClass:CPSlider] 
      setValue:[[sender stringValue] intValue]];
  }
}

- (CPAction)setRotationValue:(id)sender
{
  if ( [sender isKindOfClass:CPTextField] ) {
    [m_rotation_slider setValue:[[sender stringValue] intValue]];
  } else {
    [m_rotation_field setStringValue:(""+[sender intValue])];
  }
}

- (CPAction)updateColor:(id)sender
{
  [m_pageElement setHighlightColor:[m_color_well_bgcolor color]];
  [m_rounded_corners_example setBackgroundColor:[m_color_well_bgcolor color]];
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

- (CPAction)cancel:(id)sender
{
  [m_pageElement setHighlightColor:m_originalColor];
  [super cancel:sender];
}

- (CPAction)accept:(id)sender
{
  var selectors = [ @selector(setCornerTopLeft:), @selector(setCornerTopRight:),
                    @selector(setCornerBottomLeft:),@selector(setCornerBottomRight:)];
  for ( var idx = 0; idx < 4; idx++ ) {
    [m_pageElement performSelector:selectors[idx]
                        withObject:[[self findViewWithTag:idx
                                                  inViews:[m_view_rounded_corners subviews]
                                                  ofClass:CPSlider] intValue]];
  }
  [m_pageElement setRotation:[m_rotation_slider intValue]];
  [m_pageElement setHighlightColor:[m_color_well_bgcolor color]];
  [m_pageElement setLinkUrl:[m_link_field stringValue]];
  [m_pageElement setBorderWidth:[m_slider_border_width intValue]];
  [m_pageElement updateServer];
  [_window close];
}

//
// Helpers
//
- (void) updateBorderWidthValueTextField
{
  var str = [CPString stringWithFormat:"%d px", [m_slider_border_width intValue]];
  [m_width_value setStringValue:str];
}

- (CPArray)findViewWithTag:(int)aTagValue
                   inViews:(CPArray)subviewsToCheck
                   ofClass:(id)aClass 
{
  var cnt = [subviewsToCheck count];
  for ( var idx = 0; idx < cnt; idx++ ) {
    if ( [subviewsToCheck[idx] isKindOfClass:aClass] && 
         [subviewsToCheck[idx] tag] == aTagValue ) {
      return subviewsToCheck[idx];
    }
  }
  return nil;
}

- (void)setCornerSliders:(CPArray)cornerValues
{
  for ( var idx = 0; idx < 4; idx++ ) {
    var slider = [self findViewWithTag:idx
                               inViews:[m_view_rounded_corners subviews]
                               ofClass:CPSlider];
    [slider setIntValue:cornerValues[idx]];
    var textField = [self findViewWithTag:idx
                                  inViews:[m_view_rounded_corners subviews]
                                  ofClass:CPTextField];
    [textField setStringValue:(""+cornerValues[idx])];
  }
}

@end

