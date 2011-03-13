@implementation PropertyPublicationController : PropertyWindowController
{
  @outlet CPTextField m_snapgridField;
  @outlet CPSlider    m_snapgridSlider;
  @outlet CPView      m_snapgridView;
  @outlet CPButton    m_continousFlow;
  @outlet CPButton    m_pageShadow;
  @outlet CPColorWell m_colorWell;
  @outlet CPView      m_publicationDetailsView;

  PubConfig m_pubConfig;
}

- (void)awakeFromCib
{
  [super awakeFromCib];

  [CPBox makeBorder:m_snapgridView];
  [CPBox makeBorder:m_publicationDetailsView];
  [CPBox makeBorder:m_colorWell];
  m_pubConfig = [[ConfigurationManager sharedInstance] pubProperties];

  [m_colorWell setColor:[m_pubConfig getColor]];
  [m_continousFlow setState:([m_pubConfig isContinous] ? CPOnState : CPOffState)];
  [m_pageShadow setState:([m_pubConfig hasShadow] ? CPOnState : CPOffState)];
  [m_snapgridSlider setValue:[m_pubConfig snapGridWidth]];
  [self updateSnapgridValue];
}

- (CPAction)colorChanged:(id)sender
{
  [m_pubConfig setColor:[m_colorWell color]];
}

- (CPAction)setSnapgrid:(id)sender
{
  [self updateSnapgridValue];
}

- (CPAction)setSnapgridValue:(id)sender
{
  [m_snapgridSlider setValue:[m_snapgridField intValue]];
  [self updateSnapgridValue];
}

- (CPAction)accept:(id)sender
{
  [_window close];
  [m_pubConfig setSnapGridWidth:[m_snapgridField intValue]];
  [m_pubConfig setContinous:([m_continousFlow state] == CPOnState ? "1" : "0")];
  [m_pubConfig setShadow:([m_pageShadow state] == CPOnState ? "1" : "0")];
  [[CommunicationManager sharedInstance] publicationUpdate:m_pubConfig];
}

//
// Helpers
//
- (void) updateSnapgridValue
{
  [m_snapgridField 
    setStringValue:[CPString 
                     stringWithFormat:"%d", [m_snapgridSlider intValue]]];
  [m_pubConfig setSnapGridWidth:[m_snapgridSlider intValue]];
}

@end
