//
//  Tweak.xm
//  SmartBatteryPercentage
//
//  Created by Timm Kandziora on 10.08.14.
//  Copyright (c) 2014 Timm Kandziora. All rights reserved.
//

#import <substrate.h>

@interface SBStatusBarStateAggregator
+ (id)sharedInstance;
- (void)_updateBatteryItems;
- (BOOL)_setItem:(int)item enabled:(BOOL)enabled;
@end

static BOOL showBatteryPercentageWhileCharging = NO;
static BOOL isCharging = NO;

%hook SBStatusBarStateAggregator

- (void)_updateBatteryItems
{
    %orig;

    if (showBatteryPercentageWhileCharging) {
        [[UIDevice currentDevice] setBatteryMonitoringEnabled:YES];

        if ([[UIDevice currentDevice] batteryState] != UIDeviceBatteryStateUnplugged) {
            isCharging = YES;
        } else {
            isCharging = NO;
        }
    }

    if (isCharging) {
        [self _setItem:8 enabled:YES];
    } else {
        NSString *batteryPercentageIvar = MSHookIvar<NSString *>(self, "_batteryDetailString");
        NSString *batteryPercentageIvarFixed = [batteryPercentageIvar stringByReplacingOccurrencesOfString:@"%" withString:@""];

        if (batteryPercentageIvarFixed.intValue < 21) {
            [self _setItem:8 enabled:YES];
        } else {
            [self _setItem:8 enabled:NO];
        }
    }
}

%end

static void ReloadSettings()
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.shinvou.smartbatterypercentage.plist"];

    if (settings) {
        if ([settings objectForKey:@"showBatteryPercentageWhileCharging"]) {
            showBatteryPercentageWhileCharging = [[settings objectForKey:@"showBatteryPercentageWhileCharging"] boolValue];
            isCharging = NO;
        }
    }

    [[%c(SBStatusBarStateAggregator) sharedInstance] _updateBatteryItems];
}

// Ugly workaround since SBStatusBarStateAggregator has no shared instance yet (I guess) when %ctor is executed
static void ReloadSettingsOnStartup()
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.shinvou.smartbatterypercentage.plist"];

    if (settings) {
        if ([settings objectForKey:@"showBatteryPercentageWhileCharging"]) {
            showBatteryPercentageWhileCharging = [[settings objectForKey:@"showBatteryPercentageWhileCharging"] boolValue];
            isCharging = NO;
        }
    }
}

%ctor {
	@autoreleasepool {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ReloadSettings, CFSTR("com.shinvou.smartbatterypercentage/reloadSettings"), NULL, CFNotificationSuspensionBehaviorCoalesce);

		ReloadSettingsOnStartup();
    }
}
