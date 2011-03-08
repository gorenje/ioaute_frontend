@implementation PropertyYouTubeSeekToLinkTEController : PropertyWindowController
{
  @outlet CPColorWell m_colorWell;
  @outlet CPTextField m_linkTitle;
  @outlet CPTextField m_videoIdField;

  @outlet CPTextField   m_fontSizeLabel;
  @outlet CPPopUpButton m_fontNameButton;
  @outlet CPSlider      m_fontSizeSlider;

  @outlet CPView m_fontView;
  @outlet CPView m_videoInfoView;
  @outlet CPView m_endAtView;

  @outlet CPButton m_setEndAt;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [CPBox makeBorder:m_fontView];
  [CPBox makeBorder:m_videoInfoView];

  [m_fontNameButton removeAllItems];
  var availableFonts = [[CPFontManager sharedFontManager] availableFonts];
  for(var idx = 0; idx < [availableFonts count]; idx++) {
    var font = [availableFonts objectAtIndex:idx];
    var menuItem = [[CPMenuItem alloc] initWithTitle:font action:NULL keyEquivalent:nil];
    [menuItem setFont:[CPFont fontWithName:font size:11.0]];
    [m_fontNameButton addItem:menuItem];
  }

  [m_fontNameButton selectItemWithTitle:[m_pageElement fontName]];
  [m_fontSizeSlider setDoubleValue:[m_pageElement fontSize]];

  [m_linkTitle setStringValue:[m_pageElement linkText]];
  [m_colorWell setColor:[m_pageElement getColor]];

  [m_fontSizeLabel setStringValue:[CPString stringWithFormat:"%0.2f", 
                                            [m_fontSizeSlider doubleValue]]];

  var popUps = [self obtainEndAtPopUps:[m_endAtView subviews]];
  [self addItemsStartAt:0 endAt:25 toPopUp:popUps[0]];
  [self addItemsStartAt:0 endAt:60 toPopUp:popUps[1]];
  [self addItemsStartAt:0 endAt:60 toPopUp:popUps[2]];
  if ( [m_pageElement endAt] > 0 ) {
    [m_setEndAt setState:CPOnState];
    [m_endAtView setHidden:NO];
    
  } else {
    [m_setEndAt setState:CPOffState];
    [m_endAtView setHidden:YES];

    [popUps[0] selectItemWithTitle:"00"];
    [popUps[1] selectItemWithTitle:"00"];
    [popUps[2] selectItemWithTitle:"00"];
  }
  
}

- (CPAction)endAtToggled:(id)sender
{
  switch ( [m_setEndAt state] ) {
  case CPOffState:
    [m_endAtView setHidden:YES];
    break;
  case CPOnState:
    [m_endAtView setHidden:NO];
    break;
  }
}

- (CPAction)fontNameSelected:(id)sender
{
  [m_pageElement setFontName:[[m_fontNameButton selectedItem] title]];
}

- (CPAction)fontSizeSliderAction:(id)sender
{
  [m_fontSizeLabel setStringValue:[CPString stringWithFormat:"%0.2f", 
                                            [m_fontSizeSlider doubleValue]]];
  [m_pageElement setFontSize:[m_fontSizeSlider doubleValue]];
}

- (CPAction)updateColor:(id)sender
{
  [m_pageElement setTextColor:[m_colorWell color]];
}

- (CPAction)accept:(id)sender
{
  [m_pageElement setLinkText:[m_linkTitle stringValue]];
  [m_pageElement updateServer];
  [_window close];
}

//
// Helpers
//
- (void)addItemsStartAt:(int)aStart endAt:(int)anEnd toPopUp:(id)aPopUp
{
  [aPopUp removeAllItems];
  for(var idx = aStart; idx < anEnd; idx++) {
    var menuItem = [[CPMenuItem alloc] 
                     initWithTitle:[CPString stringWithFormat:"%02d", idx]
                            action:NULL 
                     keyEquivalent:nil];
    [aPopUp addItem:menuItem];
  }
}

- (CPArray)obtainStartAtPopUps:(CPArray)subviewsToCheck
{
  var ary = [];
  var cnt = [subviewsToCheck count];
  for ( var idx = 0; idx < cnt; idx++ ) {
    if ( "CPPopUpButton" == [subviewsToCheck[idx] class] ) {
      switch ( [subviewsToCheck[idx] tag] ) {
      case 1: ary[0] = subviewsToCheck[idx]; break;
      case 2: ary[1] = subviewsToCheck[idx]; break;
      case 4: ary[2] = subviewsToCheck[idx]; break;
      }
    }
  }
  return ary;
}

- (CPArray)obtainEndAtPopUps:(CPArray)subviewsToCheck
{
  var ary = [];
  var cnt = [subviewsToCheck count];
  for ( var idx = 0; idx < cnt; idx++ ) {
    if ( "CPPopUpButton" == [subviewsToCheck[idx] class] ) {
      CPLogConsole( "Found class tag:  " + idx + ": " + [subviewsToCheck[idx] tag] );
      switch ( parseInt([subviewsToCheck[idx] tag]) ) {
      case  8: ary[0] = subviewsToCheck[idx]; break;
      case 16: ary[1] = subviewsToCheck[idx]; break;
      case 32: ary[2] = subviewsToCheck[idx]; break;
      }
    }
  }
  return ary;
}

@end
