@implementation PropertyPublicationController : PropertyWindowController
{
  @outlet CPTextField m_snapgridField;
  @outlet CPSlider    m_snapgridSlider;
  @outlet CPView      m_snapgridView;
  @outlet CPButton    m_continousFlow;
  @outlet CPButton    m_pageShadow;
  @outlet CPColorWell m_colorWell;
  @outlet CPView      m_publicationDetailsView;

  id _json; // used to make it easier to the get the color.
  CPString m_continous;
  CPString m_has_shadow;
  CPString m_snap_grid_width;
}

- (void)awakeFromCib
{
  [super awakeFromCib];

  [CPBox makeBorder:m_snapgridView];
  [CPBox makeBorder:m_publicationDetailsView];
  [CPBox makeBorder:m_colorWell];

  _json = PublicationConfig.color;
  [PageElementColorSupport addToClassOfObject:self];
  [self setColorFromJson];
  [m_colorWell setColor:[self getColor]];

  if ( parseInt(PublicationConfig.continous) > 0 ) {
    [m_continousFlow setState:CPOnState];
  } else {
    [m_continousFlow setState:CPOffState];
  }

  if ( parseInt(PublicationConfig.shadow) > 0 ) {
    [m_pageShadow setState:CPOnState];
  } else {
    [m_pageShadow setState:CPOffState];
  }

  SnapGridSpacingSize = parseInt(PublicationConfig.snap_grid_width);
  [m_snapgridSlider setValue:SnapGridSpacingSize];
  [self updateSnapgridValue];
}

- (CPAction)colorChanged:(id)sender
{
  [self setColor:[m_colorWell color]];
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
  m_continous = [m_continousFlow state] == CPOnState ? 1 : 0;
  m_has_shadow = [m_pageShadow state] == CPOnState ? 1 : 0;
  m_snap_grid_width = SnapGridSpacingSize;
  [[CommunicationManager sharedInstance] publicationUpdate:self];
}

- (void)requestCompleted:(JSObject)data
{
  [_window close];
  switch ( data.action ) {
  case "publications_update":
    if ( data.status == "ok" ) {
      PublicationConfig = data.data;
    }
  }
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
