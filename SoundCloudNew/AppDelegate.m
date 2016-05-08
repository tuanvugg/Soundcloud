//
//  AppDelegate.m
//  SoundCloudNew
//
//  Created by Trung Đức on 1/24/16.
//  Copyright © 2016 Trung Đức. All rights reserved.
//

#import "AppDelegate.h"
#import <MagicalRecord/MagicalRecord.h>
#import "Constant.h"
#import "Playlist.h"
#import "SoundCloudAPI.h"
#import "Genre.h"
#import "Constant.h"
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.

    NSError *setCategoryErr = nil;
    NSError *activationErr  = nil;
    
    
    [[AVAudioSession sharedInstance] setCategory: AVAudioSessionCategoryPlayback error:&setCategoryErr];
    [[AVAudioSession sharedInstance] setActive:YES error:&activationErr];
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    
    //Set up CoreData
    [MagicalRecord setupCoreDataStackWithAutoMigratingSqliteStoreNamed:kDatabaseName];
    
    [self setUpForFirstTimeUse];
    
    [self.window setTintColor: kAppColor];
    //set color Tab bar
    [[UITabBar appearance] setTintColor:kAppColor];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    
    //Save data when the user quits
    [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* error) {
        if (contextDidSave) {
            NSLog(@"Data in default context SAVED");
        }
        if (error) {
            NSLog(@"Data in default context ERROR %@", error);
        }
    }];
    
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [MagicalRecord cleanUp];
}

- (void)setUpForFirstTimeUse;
{
    
    //Get data
    if (![[NSUserDefaults standardUserDefaults] boolForKey:@"HasLaunchedOnce"])
    {
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"HasLaunchedOnce"];
        
        //Set Appcolor
        NSData *colorData = [NSKeyedArchiver archivedDataWithRootObject:kAppDefaultColor];
        [[NSUserDefaults standardUserDefaults] setObject:colorData forKey:@"AppColor"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        //Creat history playlist
        [Playlist createPlaylistWithTitle:@"History"];
        
        //Get genres
        [sSoundCloudAPI exploreGenresWithCompletionBlock:^(NSArray *genreDict) {
            for (NSString *genreCode in genreDict) {
                [Genre creatWithCode:genreCode];
            }
            
            
            //save data
            [[NSManagedObjectContext MR_defaultContext] MR_saveToPersistentStoreWithCompletion:^(BOOL contextDidSave, NSError* error) {
                if (contextDidSave) {
                    NSLog(@"Data in default context SAVED");
                }
                if (error) {
                    NSLog(@"Data in default context ERROR %@", error);
                }
            }];
        }];
    }
}
- (void)application:(UIApplication *)application handleEventsForBackgroundURLSession:(NSString *)identifier
  completionHandler:(void (^)())completionHandler
{
    self.backgroundSessionCompletionHandler = completionHandler;
}


@end
