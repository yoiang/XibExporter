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

enum ViewExporterFormat
{
    ViewExporterFormatJSON=0,
    ViewExporterFormatXML,
    ViewExporterFormatPlist,
    ViewExporterFormatOpenFramework
} typedef ViewExporterFormat;

@interface ViewExporter : NSObject
{
    NSMutableDictionary *exportedData;
    NSDictionary *codeMap;
}
@property (strong) NSMutableDictionary *exportedData;
@property (strong) NSDictionary *codeMap;

- (void) processAllXibs;
- (void) processXib:(NSString *)xibName;
- (NSArray *) exportDataTo:(NSString *)location atomically:(BOOL)flag format:(ViewExporterFormat)format error:(NSError**)error saveMultipleFiles:(BOOL)mult useOnlyModifiedFiles:(BOOL)onlyModified;
- (NSArray *) exportDataToProject:(BOOL)useProjectDir atomically:(BOOL)flag format:(ViewExporterFormat)format error:(NSError**)error saveMultipleFiles:(BOOL)mult useOnlyModifiedFiles:(BOOL)onlyModified;

//helpers
- (NSString *) getStringRepresentation:(id)value key:( NSString* )key outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes properties:(NSMutableDictionary *)properties;
- (NSString *) replaceCodeSymbols:(NSString *)line dict:(NSDictionary *)dict key:(NSString *)key name:(NSString *)name outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes def:(NSDictionary *)def properties:(NSMutableDictionary *)properties;
- (NSDictionary *) getCodeFor:(NSMutableDictionary *)dict isInline:(BOOL)isInline outlets:(NSMutableDictionary *)outlets includes:(NSMutableArray *)includes properties:(NSMutableDictionary *)properties;
- (void) exportXMLTo:(NSString *)location atomically:(BOOL)flag error:(NSError**)error;
- (NSArray *) exportCodeTo:(NSString *)location atomically:(BOOL)flag error:(NSError**)error saveMultipleFiles:(BOOL)mult useOnlyModifiedFiles:(BOOL)onlyModified;
- (void) doCodeExport:(NSString *)location data:(NSDictionary *)data keys:(NSArray *)keys atomically:(BOOL)flag error:(NSError**)error;

- ( NSArray * ) exportCodeForDict:(NSDictionary *)dict def:(NSDictionary *)def properties:(NSDictionary *)properties;

- ( NSString * ) translateCodeString:(NSString *)classFile dict:(NSDictionary *)dict withDef:(NSDictionary *)def properties:(NSDictionary *)properties;
- ( NSString * ) translateSingleObjectCodeString:(NSString *)codeString dict:(NSDictionary *)dict withDef:(NSDictionary *)def properties:(NSDictionary *)properties;

@end
