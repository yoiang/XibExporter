//
//  ExportedViewMap.m
//  XibExporter
//
//  Static class that holds various things to allow global access during export.
//
//  Created by Eli Delventhal on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ExportedViewMap.h"

static ExportedViewMap *instance;

@implementation ExportedViewMap

@synthesize viewIdMap;

+ (ExportedViewMap *) sharedInstance
{
    if (!instance)
    {
        instance = [[ExportedViewMap alloc] init];
    }
    return instance;
}

- (id) init
{
    if (self = [super init])
    {
        self.viewIdMap = [NSMutableDictionary dictionary];
        return self;
    }
    return nil;
}

- (int) getViewId:(UIView*)view
{
    NSNumber *num = [self.viewIdMap objectForKey:[NSNumber numberWithInt:[view hash]]];
    if (!num)
    {
        return -1;
    }
    return [num intValue];
}

- (void) setId:(int)viewId forView:(UIView *)view
{
    [self.viewIdMap setObject:[NSNumber numberWithInt:viewId] forKey:[NSNumber numberWithInt:[view hash]]];
}

@end
