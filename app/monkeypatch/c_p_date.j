/*
    Taken from:
          https://github.com/Me1000/CappuTweetie/blob/master/RelativeDateFormatter.j
*/

@implementation CPDate (RelativeDate)

- (CPString)relativeDateSinceNow
{
    var result = nil,
        timeSinceMinutes = -[self timeIntervalSinceNow] / 60.0, // in minutes
        timeSinceHours = timeSinceMinutes / 60,
        timeSinceDays = timeSinceHours / 24,
        timeSinceYears = timeSinceDays / 365; // This is actually wrong since we need to factor in leap years, but it's close enough... ;)

    // If under 48 hours, report relative time
    var value,
        units;

    if (timeSinceMinutes <= 1.5)
    {
        // report in seconds
        value = FLOOR(timeSinceMinutes * 60.0);
        units = @"second";
    }
    else if (timeSinceMinutes < 60.0)
    {
        // report in minutes
        value = FLOOR(timeSinceMinutes);
        units = @"minute";
    }
    else if (timeSinceHours < 24)
    {
        // report in hours
        value = FLOOR (timeSinceHours);
        units = @"hour";
    }
    else if (timeSinceDays < 365)
    {
        // report in days
        value = FLOOR (timeSinceDays);
        units = @"day";
    }
    else
    {
        // report in years
        value = FLOOR (timeSinceYears);
        units = @"year";
    }

    if (value == 1)
        result = [CPString stringWithFormat:@"1 %@ ago", units];
    else
        result = [CPString stringWithFormat:@"%d %@s ago", value, units];

    return result;
}
@end
