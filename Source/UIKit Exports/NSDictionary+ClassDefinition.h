//
//  NSDictionary+ClassDefinition.h
//  XibExporter
//
//  Created by Ian on 9/30/13.
//
//

#import <Foundation/Foundation.h>

#define NSDictionary_ClassDefinition_ClassNameKey @"class"

@interface NSDictionary (ClassDefinition)

-(NSString*)className;

@end
