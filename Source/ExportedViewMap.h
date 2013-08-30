//
//  ExportedViewMap.h
//  XibExporter
//
//  Created by Eli Delventhal on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ExportedViewMap : NSObject
{
    NSMutableDictionary *viewIdMap;
}

@property (strong) NSMutableDictionary *viewIdMap;

+ (ExportedViewMap *) sharedInstance;
- (int) getViewId:(UIView*)view;
- (void) setId:(int)viewId forView:(UIView *)view; 

@end
