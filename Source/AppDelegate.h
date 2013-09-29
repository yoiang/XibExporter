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
}

+(AppDelegate*)sharedInstance;

@property (strong, readonly) XibResources *xibResources;

@end
