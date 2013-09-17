//
//  ofxGenericViewExporter.h
//  XibExporter
//
//  Created by Ian on 9/17/13.
//
//

#import <Foundation/Foundation.h>

#import "ViewExporter.h"

@interface ofxGenericViewExporter : NSObject<ViewExporter>

@end
/*

 
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
 
 - (NSArray *)exportData:(ViewGraphs*)viewGraphs toProject:(BOOL)useProjectDir atomically:(BOOL)flag format:(ViewExporterFormat)format error:(NSError**)error saveMultipleFiles:(BOOL)mult useOnlyModifiedFiles:(BOOL)onlyModified;
 
 @end
*/