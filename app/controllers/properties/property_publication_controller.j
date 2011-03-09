@implementation PropertyPublicationController : PropertyWindowController
{
  @outlet CPTextField m_snapgridField;
  @outlet CPSlider    m_snapgridSlider;
  @outlet CPView      m_snapgridView;
  @outlet CPButton    m_continousFlow;
  @outlet CPButton    m_pageShadow;
  @outlet CPColorWell m_colorWell;
  @outlet CPView      m_publicationDetailsView;
}


- (void)awakeFromCib
{
  [super awakeFromCib];
  [CPBox makeBorder:m_snapgridView];
  [CPBox makeBorder:m_publicationDetailsView];
  [CPBox makeBorder:m_colorWell];
  [m_snapgridSlider setValue:SnapGridSpacingSize];
  [self updateSnapgridValue];
}

- (CPAction)setSnapgrid:(id)sender
{
  [self updateSnapgridValue];
}

- (CPAction)setSnapgridValue:(id)sender
{
  [m_snapgridSlider setValue:parseInt([m_snapgridField stringValue])];
  [self updateSnapgridValue];
}

- (CPAction)accept:(id)sender
{
  SnapGridSpacingSize = parseInt([m_snapgridField stringValue]);
  if ( SnapGridSpacingSize > 0 ) {
    [DocumentViewCellWithSnapgrid addToClass:DocumentViewCell];
  } else {
    [DocumentViewCellWithoutSnapgrid addToClass:DocumentViewCell];
  }
  [_window close];
}

//
// Helpers
//
- (void) updateSnapgridValue
{
  var str = [CPString stringWithFormat:"%d", 
                      parseInt([m_snapgridSlider doubleValue])];
  [m_snapgridField setStringValue:str];
}

@end
