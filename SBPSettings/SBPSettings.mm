#import <Preferences/Preferences.h>

#define settingsPath @"/var/mobile/Library/Preferences/com.shinvou.smartbatterypercentage.plist"

@interface SBPSettingsListController: PSListController { }
@end

@implementation SBPSettingsListController

- (id)specifiers
{
    if (_specifiers == nil) {
        NSMutableArray *specifiers = [[NSMutableArray alloc] init];
        
        [self setTitle:@"SBP"];
        
        PSSpecifier *firstGroup = [PSSpecifier groupSpecifierWithName:@"percentage while charging"];
        [firstGroup setProperty:@"Even if this is turned off, when battery percentage hits 20% or below (or your custom set percentage) it will be shown anyways." forKey:@"footerText"];
        
        PSSpecifier *showalways = [PSSpecifier preferenceSpecifierNamed:@"Show always"
                                                              target:self
                                                                 set:@selector(setValue:forSpecifier:)
                                                                 get:@selector(getValueForSpecifier:)
                                                              detail:Nil
                                                                cell:PSSwitchCell
                                                                edit:Nil];
        [showalways setIdentifier:@"showalways"];
        [showalways setProperty:@(YES) forKey:@"enabled"];
        
        PSSpecifier *secondGroup = [PSSpecifier groupSpecifierWithName:@"set custom percentage"];
        [secondGroup setProperty:@"Enter the percentage: 2 means 2% and 37 means 37%, alright? \n\nIf you'd enter 37, battery percentage will show up in your statusbar when it's 37% or below. " forKey:@"footerText"];
        
        PSSpecifier *custompercentage = [PSSpecifier preferenceSpecifierNamed:@"Enabled"
                                                                       target:self
                                                                          set:@selector(setValue:forSpecifier:)
                                                                          get:@selector(getValueForSpecifier:)
                                                                       detail:Nil
                                                                         cell:PSSwitchCell
                                                                         edit:Nil];
        [custompercentage setIdentifier:@"custompercentage"];
        [custompercentage setProperty:@(YES) forKey:@"enabled"];
        
        PSSpecifier *thirdGroup = [PSSpecifier groupSpecifierWithName:@"contact developer"];
        [thirdGroup setProperty:@"Feel free to follow me on twitter for any updates on my apps and tweaks or contact me for support questions.\n \nThis tweak is Open-Source, so make sure to check out my GitHub." forKey:@"footerText"];
        
        PSSpecifier *twitter = [PSSpecifier preferenceSpecifierNamed:@"twitter"
                                                             target:self
                                                                set:nil
                                                                get:nil
                                                             detail:Nil
                                                               cell:PSLinkCell
                                                               edit:Nil];
        twitter.name = @"@biscoditch";
        twitter->action = @selector(openTwitter);
        [twitter setIdentifier:@"twitter"];
        [twitter setProperty:@(YES) forKey:@"enabled"];
        [twitter setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/SBPSettings.bundle/twitter.png"] forKey:@"iconImage"];
        
        PSSpecifier *github = [PSSpecifier preferenceSpecifierNamed:@"github"
                                                              target:self
                                                                 set:nil
                                                                 get:nil
                                                              detail:Nil
                                                                cell:PSLinkCell
                                                                edit:Nil];
        github.name = @"https://github.com/shinvou";
        github->action = @selector(openGithub);
        [github setIdentifier:@"github"];
        [github setProperty:@(YES) forKey:@"enabled"];
        [github setProperty:[UIImage imageWithContentsOfFile:@"/Library/PreferenceBundles/SBPSettings.bundle/github.png"] forKey:@"iconImage"];
        
        [specifiers addObject:firstGroup];
        [specifiers addObject:showalways];
        [specifiers addObject:secondGroup];
        [specifiers addObject:custompercentage];
        
        NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
        
        if (settings) {
            if ([settings objectForKey:@"customPercentage"]) {
                if ([[settings objectForKey:@"customPercentage"] boolValue]) {
                    PSTextFieldSpecifier *custompercentagefield = [PSTextFieldSpecifier preferenceSpecifierNamed:nil
                                                                                                          target:self
                                                                                                             set:@selector(setValue:forSpecifier:)
                                                                                                             get:@selector(getValueForSpecifier:)
                                                                                                          detail:Nil
                                                                                                            cell:PSEditTextCell
                                                                                                            edit:Nil];
                    [custompercentagefield setPlaceholder:@"Set custom percentage here ..."];
                    [custompercentagefield setIdentifier:@"custompercentagefield"];
                    [custompercentagefield setProperty:@(YES) forKey:@"enabled"];
                    [custompercentagefield setKeyboardType:UIKeyboardTypeNumberPad autoCaps:UITextAutocapitalizationTypeNone autoCorrection:UITextAutocorrectionTypeNo];
                    
                    [specifiers addObject:custompercentagefield];
                }
            }
        }
        
        [specifiers addObject:thirdGroup];
        [specifiers addObject:twitter];
        [specifiers addObject:github];
        
        _specifiers = specifiers;
    }
    
    return _specifiers;
}

- (id)getValueForSpecifier:(PSSpecifier *)specifier
{
    NSMutableDictionary *settings = [[NSMutableDictionary alloc] initWithContentsOfFile:settingsPath];
    
    if ([specifier.identifier isEqualToString:@"showalways"]) {
        if (settings) {
            if ([settings objectForKey:@"showBatteryPercentageWhileCharging"]) {
                if ([[settings objectForKey:@"showBatteryPercentageWhileCharging"] boolValue]) {
                    return [NSNumber numberWithBool:YES];
                }
            }
        }
    } else if ([specifier.identifier isEqualToString:@"custompercentage"]) {
        if (settings) {
            if ([settings objectForKey:@"customPercentage"]) {
                if ([[settings objectForKey:@"customPercentage"] boolValue]) {
                    return [NSNumber numberWithBool:YES];
                }
            }
        }
    } else if ([specifier.identifier isEqualToString:@"custompercentagefield"]) {
        if (settings) {
            if ([settings objectForKey:@"fieldData"]) {
                if ([[settings objectForKey:@"fieldData"] isEqualToString:@""]) {
                    return nil;
                } else {
                    return [settings objectForKey:@"fieldData"];
                }
            } else {
                return nil;
            }
        } else {
            return nil;
        }
    }
    
    return [NSNumber numberWithBool:NO];
}

- (void)setValue:(id)value forSpecifier:(PSSpecifier *)specifier
{
    if ([specifier.identifier isEqualToString:@"showalways"]) {
        if ([value boolValue]) {
            NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
            [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];
            [defaults setObject:value forKey:@"showBatteryPercentageWhileCharging"];
            [defaults writeToFile:settingsPath atomically:YES];
        } else {
            NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
            [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];
            [defaults setObject:value forKey:@"showBatteryPercentageWhileCharging"];
            [defaults writeToFile:settingsPath atomically:YES];
        }
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shinvou.smartbatterypercentage/reloadSettings"), NULL, NULL, TRUE);
        
    } else if ([specifier.identifier isEqualToString:@"custompercentage"]) {
        if ([value boolValue]) {
            NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
            [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];
            [defaults setObject:value forKey:@"customPercentage"];
            [defaults writeToFile:settingsPath atomically:YES];
            
            PSTextFieldSpecifier *custompercentagefield = [PSTextFieldSpecifier preferenceSpecifierNamed:nil
                                                                                                  target:self
                                                                                                     set:@selector(setValue:forSpecifier:)
                                                                                                     get:@selector(getValueForSpecifier:)
                                                                                                  detail:Nil
                                                                                                    cell:PSEditTextCell
                                                                                                    edit:Nil];
            [custompercentagefield setPlaceholder:@"Set custom percentage here ..."];
            [custompercentagefield setIdentifier:@"custompercentagefield"];
            [custompercentagefield setProperty:@(YES) forKey:@"enabled"];
            [custompercentagefield setKeyboardType:UIKeyboardTypeNumberPad autoCaps:UITextAutocapitalizationTypeNone autoCorrection:UITextAutocorrectionTypeNo];
            
            [self insertSpecifier:custompercentagefield atIndex:4 animated:YES];
            [self performSelector:@selector(reloadHelper) withObject:nil afterDelay:0.25];
        } else {
            NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
            [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];
            [defaults setObject:value forKey:@"customPercentage"];
            [defaults writeToFile:settingsPath atomically:YES];
            
            [self removeSpecifier:[self specifierAtIndex:4] animated:YES];
            [self performSelector:@selector(reloadHelper2) withObject:nil afterDelay:0.25];
        }
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shinvou.smartbatterypercentage/reloadSettings"), NULL, NULL, TRUE);
    } else if ([specifier.identifier isEqualToString:@"custompercentagefield"]) {
        NSMutableDictionary *defaults = [[NSMutableDictionary alloc] init];
        [defaults addEntriesFromDictionary:[NSDictionary dictionaryWithContentsOfFile:settingsPath]];
        [defaults setObject:value forKey:@"fieldData"];
        [defaults writeToFile:settingsPath atomically:YES];
        
        CFNotificationCenterPostNotification(CFNotificationCenterGetDarwinNotifyCenter(), CFSTR("com.shinvou.smartbatterypercentage/reloadSettings"), NULL, NULL, TRUE);
    }
}

// These reload helpers are dirty hacks to ensure the cells will reload without destroying the insert/remove animation
- (void)reloadHelper
{
    [self reloadSpecifierAtIndex:2 animated:NO];
}

- (void)reloadHelper2
{
    [self reloadSpecifierAtIndex:2 animated:NO];
}

- (void)openTwitter
{
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetbot:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetbot:///user_profile/biscoditch"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitterrific:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitterrific:///profile?screen_name=biscoditch"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"tweetings:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"tweetings:///user?screen_name=biscoditch"]];
    } else if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"twitter:"]]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"twitter://user?screen_name=biscoditch"]];
    } else {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://mobile.twitter.com/biscoditch"]];
    }
}

- (void)openGithub
{
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"https://github.com/shinvou"]];
}

@end
