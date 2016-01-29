#import "ParseNotifications.h"
#import <Parse/Parse.h>

@implementation ParseNotifications
{
  NSString *_channel;
  NSString *_message;
  NSString *_token;
}

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(subscribe:(NSString *)channel)
{
    // When users indicate they are @channel fans, we subscribe them to that channel.
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    [currentInstallation addUniqueObject: channel forKey:@"channels"];
    [currentInstallation saveInBackground];
}

RCT_EXPORT_METHOD(unsubscribe:(NSString *)channel)
{
  PFInstallation *currentInstallation = [PFInstallation currentInstallation];
  [currentInstallation removeObject: channel forKey:@"channels"];
  [currentInstallation saveInBackground];
}

RCT_EXPORT_METHOD(send:(NSDictionary *)options)
{
  
  _channel = [options objectForKey:@"channel"];
  _message = [options objectForKey:@"message"];
  
  NSDictionary *data = @{
                         @"alert" : _message,
                         @"badge" : @"Increment",
                         };
  
  // Send a notification to all devices subscribed to the @channel channel.
  PFPush *push = [[PFPush alloc] init];
  [push setChannel:_channel];
  [push setData:data];
  [push sendPushInBackground];
}

RCT_EXPORT_METHOD(clear)
{
  PFInstallation *installation = [PFInstallation currentInstallation];
    NSLog(@"Clearing the badge.");
    installation.badge = 0;
    [installation saveInBackground];
}

RCT_EXPORT_METHOD(login:(NSDictionary *)options)
{
  _token = [options objectForKey:@"token"];
  [PFUser becomeInBackground: _token block:^(PFUser *user, NSError *error) {
    if (error) {
      // The token could not be validated.
    } else {
      // The current user is now set to user.
      PFInstallation *installation = [PFInstallation currentInstallation];
      installation[@"user"] = user;
      [installation saveInBackground];
    }
  }];
}

RCT_EXPORT_METHOD(logout:(RCTResponseSenderBlock)callback)
{
  [PFUser logOut];
  callback(@[@"success!"]);
}

@end
