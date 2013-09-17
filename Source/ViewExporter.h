//
//  ViewExporter.h
//  XibExporter
//
//  The main point of entry for exports.
//
//  Created by Eli Delventhal on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchXML.h"

#import "ViewGraphs.h"

@protocol ViewExporter <NSObject>

@required

- (NSArray *)exportData:(ViewGraphs*)viewGraphs toProject:(BOOL)useProjectDir atomically:(BOOL)flag error:(NSError**)error saveMultipleFiles:(BOOL)mult useOnlyModifiedFiles:(BOOL)onlyModified;

@end
