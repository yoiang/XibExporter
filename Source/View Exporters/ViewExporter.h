//
//  ViewExporter.h
//  XibExporter
//
//  Created by Eli Delventhal on 4/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TouchXML.h"

#import "ViewGraphs.h"

@protocol ViewExporter <NSObject>

@required

@property (readonly) NSString* factoryKey;
-(NSArray*)exportData:(ViewGraphs*)viewGraphs toProject:(BOOL)useProjectDir atomically:(BOOL)flag error:(NSError**)error saveMultipleFiles:(BOOL)mult useOnlyModifiedFiles:(BOOL)onlyModified;


@end

@interface ViewExporterFactory : NSObject

+(void)registerExporter:(id<ViewExporter>)viewExporter;
+(id<ViewExporter>)exporterForKey:(NSString*)exporterKey;

@end

/*
 - (NSArray *) exportData:(ViewGraphs*)viewGraphs toFile:(NSString *)location atomically:(BOOL)flag format:(ViewExporterFormat)format error:(NSError**)error saveMultipleFiles:(BOOL)mult useOnlyModifiedFiles:(BOOL)onlyModified
 {
 //NSString *exportFolder = [[location stringByDeletingLastPathComponent] stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
 //NSLog(@"open %@",exportFolder);
 switch (format)
 {*/
/*        case ViewExporterFormatJSON:
 location = [NSString stringWithFormat:@"%@.json",[location stringByDeletingPathExtension]];
 [[viewGraphs JSONRepresentation] writeToFile:location atomically:flag encoding:NSUTF8StringEncoding error:error];
 break;
 case ViewExporterFormatPlist:
 location = [NSString stringWithFormat:@"%@.plist",[location stringByDeletingPathExtension]];
 [viewGraphs writeToFile:location atomically:flag];
 break;
 case ViewExporterFormatXML:
 location = [NSString stringWithFormat:@"%@.xml",[location stringByDeletingPathExtension]];
 [self exportXMLTo:location atomically:flag error:error];
 break;
 *//*
*/