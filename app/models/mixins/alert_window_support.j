@implementation AlertWindowSupport : MixinHelper
{
  CPAlert m_aws_alert_window;
  CPTimer m_aws_remove_alert_window;

  id m_aws_target
  SEL m_aws_selector;
}

- (void)awsShowAlertWindow:(CPString)aMsg
                     title:(CPString)aTitle 
                  interval:(int)anInterval
{
  [self awsShowAlertWindow:aMsg title:aTitle timer:anInterval delegate:nil selector:nil];
}

/*
 * Delegate and selector are called with the timer closes the alert window.
 */
- (void)awsShowAlertWindow:(CPString)aMsg
                     title:(CPString)aTitle 
                  interval:(int)anInterval
                  delegate:(id)aDelegate
                  selector:(SEL)aSelector
{
  m_aws_alert_window = [[CPAlert alloc] init];
  [m_aws_alert_window setMessageText:aMsg];
  [m_aws_alert_window setTitle:aTitle];
  [m_aws_alert_window setAlertStyle:CPInformationalAlertStyle];
  [m_aws_alert_window setEnabled:NO];
  [m_aws_alert_window setSelectable:NO];
  [m_aws_alert_window setEditable:NO];
  [m_aws_alert_window runModal];

  m_aws_target = aDelegate;
  m_aws_selector = aSelector;

  var stopInvoker = [[CPInvocation alloc] initWithMethodSignature:nil];
  [stopInvoker setTarget:self];
  [stopInvoker setSelector:@selector(awsCloseAlertWindow)];
  m_aws_remove_alert_window = [CPTimer scheduledTimerWithTimeInterval:anInterval
                                                           invocation:stopInvoker
                                                              repeats:NO];
}

- (void)awsCloseAlertWindowImmediately
{
  [m_aws_remove_alert_window invalidate];
  [m_aws_alert_window close];
}

- (void)awsCloseAlertWindow
{
  [self awsCloseAlertWindowImmediately];
  if ( m_aws_target && m_aws_selector ) [m_aws_target performSelector:m_aws_selector];
}

@end
