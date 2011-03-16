@implementation PropertyPublicationController : PropertyWindowController
{
  @outlet CPTextField m_snapgridField;
  @outlet CPTextField m_titleField;
  @outlet CPSlider    m_snapgridSlider;
  @outlet CPView      m_snapgridView;
  @outlet CPButton    m_continousFlow;
  @outlet CPButton    m_pageShadow;
  @outlet CPColorWell m_colorWell;
  @outlet CPView      m_publicationDetailsView;
  @outlet CPView      m_titleView;

  PubConfig m_pubConfig;
  CPColor   m_origColor;
  int       m_origSnapGridWidth;
}

- (void)awakeFromCib
{
  [super awakeFromCib];

  [CPBox makeBorder:m_snapgridView];
  [CPBox makeBorder:m_publicationDetailsView];
  [CPBox makeBorder:m_colorWell];
  [CPBox makeBorder:m_titleView];

  m_pubConfig = [[ConfigurationManager sharedInstance] pubProperties];
  m_origColor = [m_pubConfig getColor];
  m_origSnapGridWidth = [m_pubConfig snapGridWidth];

  [m_colorWell setColor:[m_pubConfig getColor]];
  [m_continousFlow setState:([m_pubConfig isContinous] ? CPOnState : CPOffState)];
  [m_pageShadow setState:([m_pubConfig hasShadow] ? CPOnState : CPOffState)];
  [m_snapgridSlider setValue:[m_pubConfig snapGridWidth]];
  [m_titleField setStringValue:[m_pubConfig pubName]];
  [self updateSnapgridValue];
  [_window makeFirstResponder:m_titleField];
}

- (CPAction)colorChanged:(id)sender
{
  [m_pubConfig setBgColor:[m_colorWell color]];
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

- (CPAction)cancel:(id)sender
{
  [super cancel:sender];
  [m_pubConfig setBgColor:m_origColor];
  [m_pubConfig setSnapGridWidth:m_origSnapGridWidth];
}

- (CPAction)accept:(id)sender
{
  [_window close];
  [m_pubConfig setPubName:[m_titleField stringValue]];
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
