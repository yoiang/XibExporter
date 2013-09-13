//
//  AppDelegate.m
//  XibExporter
//
//  Created by Eli Delventhal on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"
#import "UIImageView+Exports.h"
#import "UIViewController+Exports.h"
#import "MethodSwizzler.h"
#import "ViewExporter.h"
#import "AccessibilityStarter.h"
#import "XcodeProjectHelper.h"

@implementation AppDelegate

@synthesize window = _window;
@synthesize mainViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AccessibilityStarter startAccessibility];

    [UIViewController initializeStorage];
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.mainViewController = [[MainWindowViewController alloc] initWithNibName:@"MainWindow" bundle:[NSBundle mainBundle]];
    self.window.rootViewController = self.mainViewController;
    
    NSError *error = nil;
    [[ViewExporter sharedInstance] processAllXibs];
    NSArray *files = [[ViewExporter sharedInstance] exportDataToProject:YES atomically:NO format:ViewExporterFormatOpenFramework error:&error saveMultipleFiles:YES useOnlyModifiedFiles:YES];
     
    if (error)
    {
        NSLog(@"Couldn't export xibs: %@",error);
    }
    else
    {
        [[ViewExporter sharedInstance] exportDataToProject:NO atomically:NO format:ViewExporterFormatJSON error:&error saveMultipleFiles:NO useOnlyModifiedFiles:NO];
        
        if (error)
        {
            NSLog(@"Couldn't export json: %@",error);
        }
        
        if ( [XcodeProjectHelper addExportsToProject] )
        {
            //write to the xcodeproj file
            [XcodeProjectHelper addToXcodeProject:files];
        }
    }
    
    exit(0);
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    [AccessibilityStarter stopAccessibility];
}

@end
