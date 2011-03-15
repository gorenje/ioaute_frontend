@implementation PromptWindowController : CPWindowController
{
  @outlet CPTextField m_inputField;
  @outlet CPTextField m_label;
  @outlet CPView      m_borderView;

  CPString m_prompt       @accessors(property=prompt);
  CPString m_defaultValue @accessors(property=defaultValue);
  id       m_delegate     @accessors(property=delegate);
  SEL      m_selector     @accessors(property=selector);
}

- (void)runModal
{
  [self loadWindow];
  [m_label setStringValue:m_prompt];
  [_window makeFirstResponder:m_inputField];
  [CPApp runModalForWindow:_window];
}

- (void)awakeFromCib
{
  [CPBox makeBorder:m_borderView];
}

- (CPAction)accept:(id)sender
{
  [CPApp abortModal];
  [_window close];
  var value = [[m_inputField stringValue] stringByTrimmingWhitespace];
  [m_delegate performSelector:m_selector
                   withObject:([value isBlank] ? m_defaultValue : value)];
}

- (CPAction)cancel:(id)sender
{
  [CPApp abortModal];
  [_window close];
  [m_delegate performSelector:m_selector withObject:m_defaultValue];
}

@end
