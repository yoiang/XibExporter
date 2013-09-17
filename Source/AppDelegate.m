//
//  AppDelegate.m
//  XibExporter
//
//  Created by Eli Delventhal on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "AppDelegate.h"

#import "AppSettings.h"

#import "UIImageView+Exports.h"
#import "UIViewController+Exports.h"

#import "ViewExporter.h"
#import "AccessibilityStarter.h"

#import "XcodeProjectHelper.h"

#import "NSArray+NSString.h"

#import "ViewGraphs.h"

#import "ViewExporter.h"
#import "ofxGenericViewExporter.h"

#import "XibResources.h"

@interface AppDelegate()
{
    XibResources *_xibResources;
}

@property (nonatomic, strong) ViewGraphs *viewGraphs;

@end

@implementation AppDelegate

@synthesize xibResources = _xibResources;

+(AppDelegate*)sharedInstance
{
    AppDelegate* result = nil;
    
    id<UIApplicationDelegate> delegate = [ [UIApplication sharedApplication] delegate ];
    if ( [delegate isKindOfClass:[AppDelegate class] ] )
    {
        result = (AppDelegate*)delegate;
    }
    
    return result;
}

@synthesize window = _window;
@synthesize mainViewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [AccessibilityStarter startAccessibility];
    
    [self registerViewExporters];

    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    [self.window makeKeyAndVisible];
    self.mainViewController = [[MainWindowViewController alloc] initWithNibName:@"MainWindow" bundle:[NSBundle mainBundle]];
    self.window.rootViewController = self.mainViewController;

    _xibResources = [ [XibResources alloc] init];
    
    NSError *error = nil;
    self.viewGraphs = [ [ViewGraphs alloc] init];
    
    [self processAllXibs];

    for (NSString* exporterKey in [AppSettings getEnabledExports] )
    {
        id<ViewExporter> exporter = [ViewExporterFactory exporterForKey:exporterKey];
        if (exporter)
        {
            NSArray *files = [exporter exportData:self.viewGraphs toProject:YES atomically:NO error:&error saveMultipleFiles:YES useOnlyModifiedFiles:YES];
            if (error)
            {
                NSLog(@"Error while exporting xibs with exporter %@: %@", exporterKey, error);
            } else
            {
                if ( [AppSettings addExportsToProject] )
                {
                    //write to the xcodeproj file
                    [XcodeProjectHelper addToXcodeProject:files];
                }
            }
        } else
        {
            NSLog(@"Error, could not find exporter for key %@", exporterKey);
        }
    }

    sleep(0.01);
    exit(0);
    
    return YES;
}

-(void)registerViewExporters
{
    NSArray* registerExporterClasses = [AppSettings getRegisterExporterClasses];
    for (NSString* className in registerExporterClasses)
    {
        Class class = NSClassFromString(className);
        if ( [class conformsToProtocol:@protocol(ViewExporter) ] )
        {
            [ViewExporterFactory registerExporter:[ [class alloc] init] ];
        } else
        {
            NSLog(@"Unable to register class %@ found in register exporter classes list, does not conform to ViewExporter protocol", className);
        }
    }
}

- (void) processAllXibs
{
    NSArray* onlyProcessXibs = [ AppSettings getProcessOnlyXibs ];
    NSArray* skipXibs = [ AppSettings getSkipXibs ];
    
    NSError *error = nil;
    NSString *rootFolder = [[[NSBundle mainBundle] pathForResource:@"XibFinder" ofType:@"txt"] stringByDeletingLastPathComponent];
    NSArray *dirContents = [[NSFileManager defaultManager] contentsOfDirectoryAtPath:rootFolder error:&error];
    
    if (error)
    {
        NSLog(@"Error reading xibs! %@",error);
    }
    else
    {
        NSPredicate *filter = [NSPredicate predicateWithFormat:@"self ENDSWITH '.nib'"];
        NSArray *xibs = [dirContents filteredArrayUsingPredicate:filter];
        
        for (int i = 0; i < [xibs count]; i++)
        {
            NSString *xibName = [[[xibs objectAtIndex:i] lastPathComponent] stringByDeletingPathExtension];
            
            if ( [ onlyProcessXibs count ] > 0 )
            {
                if ( [ onlyProcessXibs containsString:xibName ] )
                {
                    [ self.viewGraphs processXib:xibName ];
                }
            } else
            {
                if ( ![ skipXibs containsString:xibName ] )
                {
                    [ self.viewGraphs processXib:xibName ];
                } else
                {
                    NSLog( @"Skipping %@", xibName );
                }
            }
        }
    }
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
