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

enum ViewExporterFormat
{
    ViewExporterFormatJSON=0,
    ViewExporterFormatXML,
    ViewExporterFormatPlist,
    ViewExporterFormatofxGeneric
} typedef ViewExporterFormat;

@interface ViewExporter : NSObject
{
    NSDictionary *codeMap;
}
@property (strong) NSDictionary *codeMap;

- (NSArray *) exportData:(ViewGraphs*)viewGraphs toProject:(BOOL)useProjectDir atomically:(BOOL)flag format:(ViewExporterFormat)format error:(NSError**)error saveMultipleFiles:(BOOL)mult useOnlyModifiedFiles:(BOOL)onlyModified;

@end
