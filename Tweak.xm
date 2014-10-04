//
//  Tweak.xm
//  SmartBatteryPercentage
//
//  Created by Timm Kandziora on 10.08.14.
//  Copyright (c) 2014 Timm Kandziora. All rights reserved.
//

@interface SBStatusBarStateAggregator
+ (id)sharedInstance;
- (void)_updateBatteryItems;
- (BOOL)_setItem:(int)item enabled:(BOOL)enabled;
@end

#define settingsPath @"/var/mobile/Library/Preferences/com.shinvou.smartbatterypercentage.plist"

static int custompercentageint = 0;
static BOOL showBatteryPercentageWhileCharging = NO;
static BOOL isCharging = NO;
static BOOL custompercentagebool = NO;

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

        int value = 20;

        if (custompercentagebool) {
            value = custompercentageint;
        }

        if (batteryPercentageIvarFixed.intValue < value + 1) {
            [self _setItem:8 enabled:YES];
        } else {
            [self _setItem:8 enabled:NO];
        }
    }
}

%end

static BOOL isAllDigits(NSString *string)
{
    NSCharacterSet *nonNumbers = [[NSCharacterSet decimalDigitCharacterSet] invertedSet];
    NSRange r = [string rangeOfCharacterFromSet:nonNumbers];
    return r.location == NSNotFound;
}

static void ReloadSettings()
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

    if (settings) {
        if ([settings objectForKey:@"showBatteryPercentageWhileCharging"]) {
            showBatteryPercentageWhileCharging = [[settings objectForKey:@"showBatteryPercentageWhileCharging"] boolValue];
            isCharging = NO;
        }

        if ([settings objectForKey:@"customPercentage"]) {
            if ([[settings objectForKey:@"customPercentage"] boolValue]) {
                if ([settings objectForKey:@"fieldData"]) {
                    if (![[settings objectForKey:@"fieldData"] isEqualToString:@""]) {
                        NSString *fieldData = [NSString stringWithFormat:@"%@", [settings objectForKey:@"fieldData"]];
                        if (isAllDigits(fieldData)) {
                            custompercentageint = [fieldData intValue];
                            custompercentagebool = [[settings objectForKey:@"customPercentage"] boolValue];
                        }
                    } else {
                        custompercentagebool = NO;
                    }
                }
            } else {
                custompercentagebool = NO;
            }
        }
    }

    [settings release];

    [[%c(SBStatusBarStateAggregator) sharedInstance] _updateBatteryItems];
}

// Ugly workaround since SBStatusBarStateAggregator has no shared instance yet (I guess) when %ctor is executed
static void ReloadSettingsOnStartup()
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];

    if (settings) {
        if ([settings objectForKey:@"showBatteryPercentageWhileCharging"]) {
            showBatteryPercentageWhileCharging = [[settings objectForKey:@"showBatteryPercentageWhileCharging"] boolValue];
            isCharging = NO;
        }

        if ([settings objectForKey:@"customPercentage"]) {
            if ([[settings objectForKey:@"customPercentage"] boolValue]) {
                if ([settings objectForKey:@"fieldData"]) {
                    if (![[settings objectForKey:@"fieldData"] isEqualToString:@""]) {
                        NSString *fieldData = [NSString stringWithFormat:@"%@", [settings objectForKey:@"fieldData"]];
                        if (isAllDigits(fieldData)) {
                            custompercentageint = [fieldData intValue];
                            custompercentagebool = [[settings objectForKey:@"customPercentage"] boolValue];
                        }
                    } else {
                        custompercentagebool = NO;
                    }
                }
            } else {
                custompercentagebool = NO;
            }
        }
    }

    [settings release];
}

%ctor {
	@autoreleasepool {
		CFNotificationCenterAddObserver(CFNotificationCenterGetDarwinNotifyCenter(), NULL, (CFNotificationCallback)ReloadSettings, CFSTR("com.shinvou.smartbatterypercentage/reloadSettings"), NULL, CFNotificationSuspensionBehaviorCoalesce);

		ReloadSettingsOnStartup();
    }
}
