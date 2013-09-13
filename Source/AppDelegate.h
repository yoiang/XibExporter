//
//  AppDelegate.h
//  XibExporter
//
//  Created by Eli Delventhal on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MainWindowViewController.h"

@class XibResources;

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    MainWindowViewController *mainViewController;
}

+(AppDelegate*)sharedInstance;

@property (strong) MainWindowViewController* mainViewController;
@property (strong, nonatomic) UIWindow *window;
@property (strong, readonly) XibResources *xibResources;

@end
