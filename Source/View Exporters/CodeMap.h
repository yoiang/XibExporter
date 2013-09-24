//
//  CodeMap.h
//  XibExporter
//
//  Created by Ian on 9/17/13.
//
//

#import <Foundation/Foundation.h>

@interface CodeMap : NSObject

-(id)initWithJSONFileName:(NSString*)jsonFileName;

@property (nonatomic, readonly) NSArray* definedClasses;
-(NSMutableDictionary*)definitionForClass:(NSString*)className;

@property (nonatomic, readonly) NSArray* definedEnums;
-(NSMutableDictionary*)definitionForEnum:(NSString*)enumName;
-(NSString*)convertEnum:(NSString*)enumName value:(NSString*)value;

-(NSArray*)definedFunctions;
-(NSString*)functionDefinition:(NSString*)function;

@property (nonatomic, readonly) NSString* rootViewInstanceName;
@property (nonatomic, readonly) NSDictionary* ignoredClasses;
@property (nonatomic, readonly) NSDictionary* asIsStringKeys;
@property (nonatomic, readonly) NSArray* codeExporterFileNames;

@property (nonatomic, readonly) NSString* statementEnd;

@end