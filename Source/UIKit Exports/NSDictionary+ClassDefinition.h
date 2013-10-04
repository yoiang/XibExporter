//
//  NSDictionary+ClassDefinition.h
//  XibExporter
//
//  Created by Ian on 9/30/13.
//
//

#import <Foundation/Foundation.h>

#define NSDictionary_ClassDefinition_ClassNameKey @"className"
#define NSDictionary_ClassDefinition_SuperClassKey @"_super"

@interface NSDictionary (ClassDefinition)

-(NSString*)className;
-(BOOL)isValidClassMember:(NSString*)memberName;

-(NSString*)asParameterToParse;
-(NSString*)asParameterWithInstance:(NSDictionary*)instanceDefinition;
-(NSString*)asParameterWithInstanceName:(NSString*)instanceName;

-(NSString*)superClassName;

-(NSString*)asInlineConstructorToParse;
-(NSString*)asConstructorToParse;

-(NSString*)asAddSubviewToParse;
-(NSString*)asAddSubViewWithInstanceName:(NSString*)instanceName andSubviewInstance:(NSDictionary*)instanceDefinition;
-(NSString*)asAddSubViewWithInstanceName:(NSString*)instanceName andSubviewInstanceName:(NSString*)subviewInstanceName;

-(NSArray*)includes;

@end
