//
//  AppDelegate.m
//  BACHome
//
//  Created by Chase Gorectke on 1/17/14.
//  Copyright (c) 2014 Revision Works, LLC. All rights reserved.
//

#import "AppDelegate.h"
#import "PFBars.h"
#import "PFDrinks.h"
#import "PFFriend.h"
#import "PFToasts.h"

@implementation AppDelegate

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    [self setupParse:launchOptions];
    return YES;
}
							
-(void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

-(void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

-(void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

-(void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

-(void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

-(void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    PFInstallation *currentInstallation = [PFInstallation currentInstallation];
    PFUser *currentUser = [PFUser currentUser];
    if (currentUser) {
        [currentInstallation setValue:currentUser.username forKey:@"username"];
    }

    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (!succeeded) {
            // The login failed. Check error to see why.
            if ([error code] == 100) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"We're Very Sorry" message:@"It seems we can't connect to the server. Please try again later. It might be an issue with the WiFi you are currently connected to." delegate:nil cancelButtonTitle:@"Ok..." otherButtonTitles:nil, nil];
                [alert show];
            } else if ([error code] == -1202) {
                NSLog(@"Error Code -1202");
            } else {
                NSLog(@"Error: %@", [error localizedDescription]);
            }
        }
    }];
}

-(void)setupParse:(NSDictionary *)launchOptions {
    [PFBars registerSubclass];
    [PFDrinks registerSubclass];
    [PFFriend registerSubclass];
    [PFToasts registerSubclass];
    
    [Parse setApplicationId:@"161eEMKACb4iY7WNGthB1T15n0yOg2nbNxd0Qsre" clientKey:@"P0g3zLxURHOB9YpeHenmKQorWLEmKeBEyhmSBPWx"];
    PFACL *defaultACL = [PFACL ACL];
    [defaultACL setPublicReadAccess:YES];
    [PFACL setDefaultACL:defaultACL withAccessForCurrentUser:YES];
    [PFAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
}

@end
