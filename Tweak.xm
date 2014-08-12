//
//  Tweak.xm
//  SmartBatteryPercentage
//
//  Created by Timm Kandziora on 10.08.14.
//  Copyright (c) 2014 Timm Kandziora. All rights reserved.
//

#import <substrate.h>

@interface SBStatusBarStateAggregator
- (void)_updateBatteryItems;
- (BOOL)_setItem:(int)item enabled:(BOOL)enabled;
@end

%hook SBStatusBarStateAggregator

- (void)_updateBatteryItems
{
    %orig;

    NSString *batteryPercentageIvar = MSHookIvar<NSString *>(self, "_batteryDetailString");
    NSString *batteryPercentageIvarFixed = [batteryPercentageIvar stringByReplacingOccurrencesOfString:@"%" withString:@""];

    if (batteryPercentageIvarFixed.intValue < 21) {
        [self _setItem:8 enabled:YES];
    } else {
        [self _setItem:8 enabled:NO];
    }
}

%end
