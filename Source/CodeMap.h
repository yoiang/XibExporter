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
@property (nonatomic, readonly) NSArray* functionDefinitions;
@property (nonatomic, readonly) NSString* rootViewInstanceName;
@property (nonatomic, readonly) NSDictionary* ignoredClasses;
@property (nonatomic, readonly) NSDictionary* asIsStringKeys;
@property (nonatomic, readonly) NSArray* codeExporterFileNames;

@end