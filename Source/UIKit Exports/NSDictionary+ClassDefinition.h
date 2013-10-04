//
//  NSDictionary+ClassDefinition.h
//  XibExporter
//
//  Created by Ian on 9/30/13.
//
//

#import <Foundation/Foundation.h>

#define NSDictionary_ClassDefinition_ClassNameKey @"className"

@interface NSDictionary (ClassDefinition)

-(NSString*)className;
-(BOOL)isValidClassMember:(NSString*)memberName;

-(NSString*)asParameterToParse;
-(NSString*)asParameterWithInstance:(NSDictionary*)instanceDefinition;
-(NSString*)asParameterWithInstanceName:(NSString*)instanceName;

@end
