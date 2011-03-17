@implementation PropertyPayPalButtonController : PropertyWindowController
{
  @outlet CPTextField   m_recipient;
  @outlet CPPopUpButton m_currency_list;

  @outlet CPButton      m_size_small;
  @outlet CPButton      m_size_large;
  @outlet CPButton      m_size_large_with_cc;
}

- (void)awakeFromCib
{
  [super awakeFromCib];
  [m_recipient setStringValue:[m_pageElement recipient]];

  [m_currency_list removeAllItems];
  [m_currency_list addItemsWithTitles:["USD", "EUR", "YEN", "GBP"]];
  [m_currency_list selectItemWithTitle:[m_pageElement currency]];
  
  switch ( [m_pageElement imageSize] ) {
  case "small":
    [m_size_small setState:CPOnState];
    break;
  case "large":
    [m_size_large setState:CPOnState];
    break;
  case "large_with_cc":
    [m_size_large_with_cc setState:CPOnState];
    break;
  }
  [self setFocusOn:m_recipient];
}

- (CPAction)changeSize:(id)sender
{
  switch ( sender ) {
  case m_size_small:
    [m_pageElement setImageSize:"small"];
    break;
  case m_size_large:
    [m_pageElement setImageSize:"large"];
    break;
  case m_size_large_with_cc:
    [m_pageElement setImageSize:"large_with_cc"];
    break;
  }
}

- (CPAction)changeCurrency:(id)sender
{
  [m_pageElement setCurrency:[[sender selectedItem] title]];
}


- (CPAction)accept:(id)sender
{
  [m_pageElement setRecipient:[m_recipient stringValue]];
  [m_pageElement updateServer];
  [_window close];
}

@end
